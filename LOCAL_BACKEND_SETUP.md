# Local Backend Setup

`RGT/regatta-tracker-main` runs the backend behind nginx on port `80`.

The mobile app already supports a configurable backend base URL via `--dart-define`.

Default behavior:

- Android emulator: `http://10.0.2.2`
- iOS simulator: `http://localhost`
- Desktop and web: `http://localhost`

Prepared config files:

- `config/api/dev_android_emulator.json`
- `config/api/dev_ios_simulator.json`
- `config/api/dev_desktop_or_web.json`
- `config/api/dev_physical_device.template.json`

Run examples:

```bash
cd vkr_regatta
flutter run --dart-define-from-file=config/api/dev_android_emulator.json
```

```bash
cd vkr_regatta
flutter run -d ios --dart-define-from-file=config/api/dev_ios_simulator.json
```

```bash
cd vkr_regatta
flutter run -d chrome --dart-define-from-file=config/api/dev_desktop_or_web.json
```

For a physical Android phone:

1. Make sure the phone and the computer are on the same Wi-Fi network.
2. Find the computer LAN address, for example `192.168.1.100`.
3. Copy `config/api/dev_physical_device.template.json` and replace the host with that LAN IP.
4. Run Flutter with `--dart-define-from-file`.

Example:

```bash
cd vkr_regatta
flutter run --dart-define-from-file=config/api/dev_physical_device.json
```

Important notes:

- Android emulator cannot reach host `localhost` directly, so it must use `10.0.2.2`.
- iOS simulator can use `localhost`.
- Physical devices cannot use `localhost` or `10.0.2.2`; they need the computer LAN IP.
- Cleartext HTTP is enabled for local development in Android and iOS app config because the local docker stack is exposed as `http://...`.
