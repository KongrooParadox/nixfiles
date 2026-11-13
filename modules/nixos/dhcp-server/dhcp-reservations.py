#!/usr/bin/env python3
"""Render dnsmasq reservations from public address facts and private MACs."""

import argparse
import ipaddress
import json
import os
import re
import sys
import tempfile
from pathlib import Path

MAC_ADDRESS = re.compile(r"(?:[0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}\Z")
HOST_NAME = re.compile(r"[a-z0-9][a-z0-9-]*\Z")


class ReservationError(ValueError):
    pass


def parse_identities(path: Path) -> dict[str, str]:
    identities = {}
    seen_macs = set()
    for line_number, raw_line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if line.count("=") != 1:
            raise ReservationError(f"identity line {line_number} must be name=MAC")

        name, mac = (part.strip() for part in line.split("=", 1))
        if not HOST_NAME.fullmatch(name):
            raise ReservationError(f"identity line {line_number} has an invalid host name")
        if name in identities:
            raise ReservationError(f"identity line {line_number} duplicates a host name")
        if not MAC_ADDRESS.fullmatch(mac):
            raise ReservationError(f"identity line {line_number} has an invalid MAC address")

        normalized_mac = mac.lower()
        if int(normalized_mac[:2], 16) & 1:
            raise ReservationError(f"identity line {line_number} has a multicast MAC address")
        if normalized_mac in seen_macs:
            raise ReservationError(f"identity line {line_number} duplicates a MAC address")

        identities[name] = normalized_mac
        seen_macs.add(normalized_mac)
    return identities


def render_reservations(facts: object, identities: dict[str, str]) -> str:
    if not isinstance(facts, dict):
        raise ReservationError("public DHCP facts must be an object")

    try:
        subnet = ipaddress.IPv4Network(facts["subnet"], strict=True)
        address_range = facts["range"]
        range_start = ipaddress.IPv4Address(address_range["start"])
        range_end = ipaddress.IPv4Address(address_range["end"])
        reservations = facts["reservations"]
        static_addresses = facts["staticAddresses"]
    except (KeyError, TypeError, ValueError) as error:
        raise ReservationError("public DHCP facts have an invalid subnet, range, or address list") from error

    if not isinstance(reservations, list) or not isinstance(static_addresses, list):
        raise ReservationError("public DHCP reservations and static addresses must be lists")
    if range_start not in subnet or range_end not in subnet or range_start > range_end:
        raise ReservationError("dynamic range must be ordered and contained in the site subnet")
    if range_start in (subnet.network_address, subnet.broadcast_address) or range_end in (
        subnet.network_address,
        subnet.broadcast_address,
    ):
        raise ReservationError("dynamic range cannot include the subnet or broadcast address")

    addresses_by_name = {}
    static_ips = set()
    for static_address in static_addresses:
        if not isinstance(static_address, dict):
            raise ReservationError("each static address fact must be an object")
        name = static_address.get("name")
        address = static_address.get("ipv4")
        if not isinstance(name, str) or not HOST_NAME.fullmatch(name):
            raise ReservationError("static address facts contain an invalid host name")
        if name in addresses_by_name:
            raise ReservationError(f"static address facts duplicate host {name}")
        if not isinstance(address, str):
            raise ReservationError(f"static address for {name} is missing")
        try:
            parsed_address = ipaddress.IPv4Address(address)
        except ipaddress.AddressValueError as error:
            raise ReservationError(f"static address for {name} is invalid") from error
        if parsed_address not in subnet or parsed_address in (
            subnet.network_address,
            subnet.broadcast_address,
        ):
            raise ReservationError(f"static address for {name} is outside the usable site subnet")
        if address in static_ips:
            raise ReservationError(f"static address facts duplicate IPv4 address {address}")
        addresses_by_name[name] = address
        static_ips.add(address)

    for name, address in addresses_by_name.items():
        parsed_address = ipaddress.IPv4Address(address)
        if range_start <= parsed_address <= range_end:
            raise ReservationError(f"dynamic range overlaps static address for {name}")

    expected_names = set()
    for reservation in reservations:
        if not isinstance(reservation, dict):
            raise ReservationError("each public DHCP reservation must be an object")
        name = reservation.get("name")
        address = reservation.get("ipv4")
        if not isinstance(name, str) or not HOST_NAME.fullmatch(name):
            raise ReservationError("DHCP reservation facts contain an invalid host name")
        if name in expected_names:
            raise ReservationError(f"DHCP reservation facts duplicate host {name}")
        if not isinstance(address, str) or addresses_by_name.get(name) != address:
            raise ReservationError(f"DHCP reservation for {name} does not match its static IP fact")
        expected_names.add(name)

    missing = sorted(expected_names - identities.keys())
    unexpected = sorted(identities.keys() - expected_names)
    if missing or unexpected:
        details = []
        if missing:
            details.append(f"missing identities for: {', '.join(missing)}")
        if unexpected:
            details.append(f"unexpected identities for: {', '.join(unexpected)}")
        raise ReservationError("; ".join(details))

    return "".join(
        f"dhcp-host={identities[name]},{addresses_by_name[name]}\n" for name in sorted(expected_names)
    )


def write_private_file(path: Path, content: str) -> None:
    path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    os.chmod(path.parent, 0o700)

    if path.exists() and path.read_text(encoding="utf-8") == content:
        os.chmod(path, 0o600)
        return

    temporary_path = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            dir=path.parent,
            prefix=f".{path.name}.",
            delete=False,
        ) as temporary_file:
            temporary_path = Path(temporary_file.name)
            os.fchmod(temporary_file.fileno(), 0o600)
            temporary_file.write(content)
            temporary_file.flush()
            os.fsync(temporary_file.fileno())
        os.replace(temporary_path, path)
    finally:
        if temporary_path is not None and temporary_path.exists():
            temporary_path.unlink()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("facts", type=Path)
    parser.add_argument("identities", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    try:
        facts = json.loads(args.facts.read_text(encoding="utf-8"))
        identities = parse_identities(args.identities)
        rendered = render_reservations(facts, identities)
        write_private_file(args.output, rendered)
    except (OSError, json.JSONDecodeError, ReservationError) as error:
        print(f"dnsmasq reservation generation failed: {error}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
