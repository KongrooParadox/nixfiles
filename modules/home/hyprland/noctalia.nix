{
  config,
  lib,
  ...
}:
let
  cfg.enabled = config.kp.hyprland.bar == "noctalia";
in
{
  config = lib.mkIf cfg.enabled {
    home.file.".cache/noctalia/wallpapers.json" = {
      text = builtins.toJSON {
        defaultWallpaper = "~/nixfiles/wallpapers/water-dragon.png";
        wallpapers = {
          "eDP-1" = "~/nixfiles/wallpapers/water-dragon.png";
          "DVI-I-1" = "~/nixfiles/wallpapers/ghibli-landscape.png";
          "DVI-I-2" = "~/nixfiles/wallpapers/vestrahorn-mountain.jpg";
        };
      };
    };
    programs.noctalia-shell = {
      enable = true;
      settings = {
        settingsVersion = 0;
        bar = {
          position = "right";
          monitors = [ ];
          density = "comfortable";
          transparent = false;
          showOutline = false;
          showCapsule = true;
          capsuleOpacity = 1.0;
          floating = false;
          marginVertical = 0.25;
          marginHorizontal = 0.45;
          outerCorners = false;
          exclusive = true;
          widgets = {
            left = [
              {
                id = "ControlCenter";
                useDistroLogo = true;
              }
              {
                id = "WallpaperSelector";
              }
              {
                id = "Workspace";
                colorizeIcons = true;
                hideUnoccupied = false;
                labelMode = "name";
              }
              {
                id = "MediaMini";
              }
            ];
            center = [
              {
                id = "ActiveWindow";
              }
              {
                id = "SystemMonitor";
                showCpuTemp = false;
                showDiskUsage = true;
                showGpuTemp = false;
              }
            ];
            right = [
              {
                id = "Battery";
              }
              {
                id = "Volume";
              }
              {
                id = "Brightness";
              }
              {
                id = "Bluetooth";
              }
              {
                id = "WiFi";
              }
              {
                id = "VPN";
              }
              {
                id = "NotificationHistory";
              }
              {
                id = "Tray";
              }
              {
                id = "Clock";
                usePrimaryColor = false;
              }
            ];
          };
        };
        general = {
          avatarImage = "~/Pictures/profile.png";
          dimmerOpacity = 0.2;
          showScreenCorners = false;
          forceBlackScreenCorners = false;
          scaleRatio = 1;
          radiusRatio = 1;
          iRadiusRatio = 1;
          boxRadiusRatio = 1;
          screenRadiusRatio = 1;
          animationSpeed = 1;
          animationDisabled = false;
          compactLockScreen = false;
          lockOnSuspend = true;
          showSessionButtonsOnLockScreen = true;
          showHibernateOnLockScreen = false;
          enableShadows = true;
          shadowDirection = "bottom_right";
          shadowOffsetX = 2;
          shadowOffsetY = 3;
          language = "";
          allowPanelsOnScreenWithoutBar = true;
        };
        ui = {
          fontDefault = lib.mkForce "JetBrainsMono Nerd Font Mono";
          fontFixed = lib.mkForce "JetBrainsMono Nerd Font Mono";
          fontDefaultScale = 1.0;
          fontFixedScale = 1.1;
          tooltipsEnabled = true;
          panelBackgroundOpacity = 1.0;
          panelsAttachedToBar = true;
          settingsPanelMode = "attached";
        };
        location = {
          name = "Tavel";
          weatherEnabled = true;
          weatherShowEffects = true;
          useFahrenheit = false;
          use12hourFormat = false;
          showWeekNumberInCalendar = true;
          showCalendarEvents = true;
          showCalendarWeather = true;
          analogClockInCalendar = false;
          firstDayOfWeek = -1;
        };
        calendar = {
          cards = [
            {
              enabled = true;
              id = "calendar-header-card";
            }
            {
              enabled = true;
              id = "calendar-month-card";
            }
            {
              enabled = true;
              id = "timer-card";
            }
            {
              enabled = true;
              id = "weather-card";
            }
          ];
        };
        screenRecorder = {
          directory = "";
          frameRate = 60;
          audioCodec = "opus";
          videoCodec = "h264";
          quality = "very_high";
          colorRange = "limited";
          showCursor = true;
          audioSource = "default_output";
          videoSource = "portal";
        };
        wallpaper = {
          enabled = true;
          overviewEnabled = false;
          directory = "~/nixfiles/wallpapers";
          monitorDirectories = [ ];
          enableMultiMonitorDirectories = false;
          recursiveSearch = false;
          setWallpaperOnAllMonitors = false;
          fillMode = "crop";
          fillColor = "#000000";
          randomEnabled = false;
          randomIntervalSec = 300;
          transitionDuration = 1500;
          transitionType = "random";
          transitionEdgeSmoothness = 0.05;
          panelPosition = "follow_bar";
          hideWallpaperFilenames = false;
          useWallhaven = false;
          wallhavenQuery = "";
          wallhavenSorting = "relevance";
          wallhavenOrder = "desc";
          wallhavenCategories = "111";
          wallhavenPurity = "100";
          wallhavenRatios = "";
          wallhavenResolutionMode = "atleast";
          wallhavenResolutionWidth = "";
          wallhavenResolutionHeight = "";
        };
        appLauncher = {
          enableClipboardHistory = false;
          enableClipPreview = true;
          position = "center";
          pinnedExecs = [ ];
          useApp2Unit = false;
          sortByMostUsed = true;
          terminalCommand = "alacritty";
          customLaunchPrefixEnabled = false;
          customLaunchPrefix = "";
          viewMode = "list";
          showCategories = true;
          iconMode = "tabler";
        };
        controlCenter = {
          position = "close_to_bar_button";
          shortcuts = {
            left = [
              {
                id = "WiFi";
              }
              {
                id = "Bluetooth";
              }
              {
                id = "ScreenRecorder";
              }
              {
                id = "WallpaperSelector";
              }
            ];
            right = [
              {
                id = "Notifications";
              }
              {
                id = "PowerProfile";
              }
              {
                id = "KeepAwake";
              }
              {
                id = "NightLight";
              }
            ];
          };
          cards = [
            {
              enabled = true;
              id = "profile-card";
            }
            {
              enabled = true;
              id = "shortcuts-card";
            }
            {
              enabled = true;
              id = "audio-card";
            }
            {
              enabled = false;
              id = "brightness-card";
            }
            {
              enabled = true;
              id = "weather-card";
            }
            {
              enabled = true;
              id = "media-sysmon-card";
            }
          ];
        };
        systemMonitor = {
          cpuWarningThreshold = 80;
          cpuCriticalThreshold = 90;
          tempWarningThreshold = 80;
          tempCriticalThreshold = 90;
          gpuWarningThreshold = 80;
          gpuCriticalThreshold = 90;
          memWarningThreshold = 80;
          memCriticalThreshold = 90;
          diskWarningThreshold = 80;
          diskCriticalThreshold = 90;
          cpuPollingInterval = 3000;
          tempPollingInterval = 3000;
          gpuPollingInterval = 3000;
          enableNvidiaGpu = false;
          memPollingInterval = 3000;
          diskPollingInterval = 3000;
          networkPollingInterval = 3000;
          useCustomColors = false;
          warningColor = "";
          criticalColor = "";
        };
        dock = {
          enabled = false;
        };
        network = {
          wifiEnabled = true;
        };
        sessionMenu = {
          enableCountdown = true;
          countdownDuration = 10000;
          position = "center";
          showHeader = true;
          largeButtonsStyle = false;
          powerOptions = [
            {
              action = "lock";
              enabled = true;
            }
            {
              action = "suspend";
              enabled = true;
            }
            {
              action = "hibernate";
              enabled = true;
            }
            {
              action = "reboot";
              enabled = true;
            }
            {
              action = "logout";
              enabled = true;
            }
            {
              action = "shutdown";
              enabled = true;
            }
          ];
        };
        notifications = {
          enabled = true;
          monitors = [ ];
          location = "bottom_right";
          overlayLayer = true;
          backgroundOpacity = 1.0;
          respectExpireTimeout = false;
          lowUrgencyDuration = 3;
          normalUrgencyDuration = 8;
          criticalUrgencyDuration = 15;
          enableKeyboardLayoutToast = true;
          sounds = {
            enabled = false;
            volume = 0.5;
            separateSounds = false;
            criticalSoundFile = "";
            normalSoundFile = "";
            lowSoundFile = "";
            excludedApps = "discord,firefox,chrome,chromium,edge";
          };
        };
        osd = {
          enabled = true;
          location = "top_left";
          autoHideMs = 2000;
          overlayLayer = true;
          backgroundOpacity = 1.0;
          enabledTypes = [
            0
            1
            2
            4
          ];
          monitors = [ ];
        };
        audio = {
          volumeStep = 5;
          volumeOverdrive = false;
          cavaFrameRate = 30;
          visualizerType = "linear";
          mprisBlacklist = [ ];
          preferredPlayer = "";
          externalMixer = "pwvucontrol || pavucontrol";
        };
        brightness = {
          brightnessStep = 5;
          enforceMinimum = true;
          enableDdcSupport = false;
        };
        colorSchemes = {
          useWallpaperColors = true;
          predefinedScheme = "Nord";
          darkMode = true;
          schedulingMode = "manual";
          manualSunrise = "06:30";
          manualSunset = "18:30";
          matugenSchemeType = "scheme-fruit-salad";
          generateTemplatesForPredefined = true;
        };
        templates = {
          gtk = true;
          qt = true;
          kcolorscheme = false;
          alacritty = true;
          kitty = false;
          ghostty = false;
          foot = false;
          wezterm = false;
          fuzzel = false;
          discord = false;
          pywalfox = false;
          vicinae = false;
          walker = false;
          code = false;
          spicetify = false;
          telegram = false;
          cava = false;
          yazi = false;
          emacs = false;
          niri = false;
          mango = false;
          zed = false;
          enableUserTemplates = false;
        };
        nightLight = {
          enabled = true;
          forced = false;
          autoSchedule = true;
          nightTemp = "4000";
          dayTemp = "6500";
          manualSunrise = "06:30";
          manualSunset = "18:30";
        };
        hooks = {
          enabled = false;
          wallpaperChange = "";
          darkModeChange = "";
          screenLock = "";
          screenUnlock = "";
          performanceModeEnabled = "";
          performanceModeDisabled = "";
        };
        desktopWidgets = {
          enabled = false;
          editMode = false;
          gridSnap = false;
          monitorWidgets = [ ];
        };
      };
    };
  };
}
