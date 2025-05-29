# Cheat Detection Tool (CDT)

![CDT Logo]([https://cdn.discordapp.com/attachments/1377354446736068794/1377689542739361852/icon.ico?ex=6839e0df&is=68388f5f&hm=d31f97f7f2b4fe4b43a04382e526eae5646a3efcd2e52fba319bbc409dbdac45&])

A comprehensive security tool for detecting cheats, exploits, and suspicious system activity. Designed for security professionals and game administrators.

## Features

- **Registry Scanning**: Detect suspicious registry entries and persistence mechanisms
- **Last Activity Analysis**: Review recent system activity including executed files and opened documents
- **Exploit Detection**: Identify known cheat software and suspicious files
- **System Information**: Gather detailed system specs and security settings
- **Automated Reporting**: Generate detailed logs of all findings

## Download and Installation

1. Download the latest release from the [Releases page](https://github.com/losttroute/CDT/releases)
2. Extract the ZIP file to your preferred location
3. Run `CDT.exe` as Administrator

## Usage

### Basic Operation

1. Launch `CDT.exe` as Administrator
2. Use the menu system to select operations:
   - **Registry Scan**: Scans for suspicious registry entries
   - **Last Activity**: Shows recent system activity
   - **Checker**: Scans for known exploits
   - **Reports**: View previously generated reports
   - **Settings**: Configure tool options

### Command Line Options

Run `CDT.exe` with these optional parameters:

CDT.exe [mode] [options]

Modes:
--scan Run registry scan immediately
--activity Run last activity analysis immediately
--checker Run cheat detection immediately
--update Check for updates

Options:
--silent Run without interactive UI
--log <path> Specify custom log directory

### Automatic Updates

CDT includes an automatic update system. When an update is available:
1. The tool will notify you on startup
2. Confirm the update when prompted
3. The updater will:
   - Download the new version
   - Replace the existing executable
   - Restart the application

## Security Considerations

- Always run as Administrator for full functionality
- The tool may be flagged by antivirus due to its deep system scanning capabilities
- Add an exception for CDT.exe in your antivirus if needed
- Logs are stored in a hidden folder on your desktop by default

## Support

For issues or feature requests:
- Open an issue on GitHub
- Contact losttroute on Discord

## License

MIT License - See [LICENSE]([LICENSE](https://github.com/losttroute/CDT/blob/main/LICENSE.md)) file for details

---

*CDT is provided as-is without warranty. Use at your own risk.*
