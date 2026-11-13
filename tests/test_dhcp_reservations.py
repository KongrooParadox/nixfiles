import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).parents[1] / "modules/nixos/dhcp-server/dhcp-reservations.py"


class DhcpReservationsTest(unittest.TestCase):
    def run_generator(
        self,
        reservations,
        identities,
        output,
        *,
        static_addresses=None,
        subnet="192.168.2.0/24",
        start="192.168.2.100",
        end="192.168.2.199",
    ):
        output.parent.mkdir(parents=True, exist_ok=True)
        facts_path = output.parent / "facts.json"
        macs_path = output.parent / "macs"
        facts_path.write_text(
            json.dumps(
                {
                    "subnet": subnet,
                    "range": {"start": start, "end": end},
                    "reservations": reservations,
                    "staticAddresses": static_addresses if static_addresses is not None else reservations,
                }
            ),
            encoding="utf-8",
        )
        macs_path.write_text(identities, encoding="utf-8")
        return subprocess.run(
            [sys.executable, str(SCRIPT), str(facts_path), str(macs_path), str(output)],
            capture_output=True,
            text=True,
            check=False,
        )

    def test_generates_stable_dnsmasq_records_and_restricts_permissions(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            output = Path(temp_dir) / "run/dnsmasq/hosts.conf"
            result = self.run_generator(
                [
                    {"name": "jetkvm", "ipv4": "192.168.2.6"},
                    {"name": "tasmota-desk", "ipv4": "192.168.2.4"},
                ],
                "tasmota-desk=02:00:00:00:00:04\njetkvm=02:00:00:00:00:06\n",
                output,
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(
                output.read_text(encoding="utf-8"),
                "dhcp-host=02:00:00:00:00:06,192.168.2.6\n"
                "dhcp-host=02:00:00:00:00:04,192.168.2.4\n",
            )
            self.assertEqual(output.stat().st_mode & 0o777, 0o600)
            self.assertEqual(output.parent.stat().st_mode & 0o777, 0o700)

    def test_rejects_missing_or_unexpected_identities_without_writing(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            output = Path(temp_dir) / "hosts.conf"
            result = self.run_generator(
                [{"name": "jetkvm", "ipv4": "192.168.2.6"}],
                "unmanaged=02:00:00:00:00:06\n",
                output,
            )

            self.assertNotEqual(result.returncode, 0)
            self.assertFalse(output.exists())
            self.assertNotIn("02:00:00:00:00:06", result.stderr)

    def test_rejects_invalid_and_duplicate_macs(self):
        cases = [
            "jetkvm=not-a-mac\n",
            "jetkvm=02:00:00:00:00:06\ntasmota=02:00:00:00:00:06\n",
        ]
        for identities in cases:
            with self.subTest(identities=identities), tempfile.TemporaryDirectory() as temp_dir:
                output = Path(temp_dir) / "hosts.conf"
                result = self.run_generator(
                    [
                        {"name": "jetkvm", "ipv4": "192.168.2.6"},
                        {"name": "tasmota", "ipv4": "192.168.2.7"},
                    ],
                    identities,
                    output,
                )
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse(output.exists())

    def test_rejects_duplicate_or_invalid_ipv4_reservations(self):
        cases = [
            [
                {"name": "jetkvm", "ipv4": "192.168.2.6"},
                {"name": "tasmota", "ipv4": "192.168.2.6"},
            ],
            [{"name": "jetkvm", "ipv4": "192.168.2.256"}],
        ]
        for reservations in cases:
            with self.subTest(reservations=reservations), tempfile.TemporaryDirectory() as temp_dir:
                output = Path(temp_dir) / "hosts.conf"
                result = self.run_generator(
                    reservations,
                    "jetkvm=02:00:00:00:00:06\ntasmota=02:00:00:00:00:07\n",
                    output,
                )
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse(output.exists())

    def test_rejects_ranges_outside_subnet_or_overlapping_reservations(self):
        cases = [
            {"start": "192.168.3.100", "end": "192.168.3.199"},
            {"start": "192.168.2.6", "end": "192.168.2.100"},
        ]
        for address_range in cases:
            with self.subTest(address_range=address_range), tempfile.TemporaryDirectory() as temp_dir:
                output = Path(temp_dir) / "hosts.conf"
                result = self.run_generator(
                    [{"name": "jetkvm", "ipv4": "192.168.2.6"}],
                    "jetkvm=02:00:00:00:00:06\n",
                    output,
                    start=address_range["start"],
                    end=address_range["end"],
                )
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse(output.exists())

    def test_rejects_dynamic_range_overlapping_other_static_hosts(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            output = Path(temp_dir) / "hosts.conf"
            result = self.run_generator(
                [{"name": "jetkvm", "ipv4": "192.168.2.6"}],
                "jetkvm=02:00:00:00:00:06\n",
                output,
                static_addresses=[
                    {"name": "jetkvm", "ipv4": "192.168.2.6"},
                    {"name": "server", "ipv4": "192.168.2.150"},
                ],
            )

            self.assertNotEqual(result.returncode, 0)
            self.assertFalse(output.exists())

    def test_rejects_duplicate_static_addresses(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            output = Path(temp_dir) / "hosts.conf"
            result = self.run_generator(
                [{"name": "jetkvm", "ipv4": "192.168.2.6"}],
                "jetkvm=02:00:00:00:00:06\n",
                output,
                static_addresses=[
                    {"name": "jetkvm", "ipv4": "192.168.2.6"},
                    {"name": "server", "ipv4": "192.168.2.6"},
                ],
            )

            self.assertNotEqual(result.returncode, 0)
            self.assertFalse(output.exists())


if __name__ == "__main__":
    unittest.main()
