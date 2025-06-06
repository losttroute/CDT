# Cheat Detection Tool (CDT)

![CDT Logo](https://cdn.discordapp.com/attachments/1377354446736068794/1377691926467182715/icon.jpg?ex=6839e317&is=68389197&hm=3970ae6abf1501457dcaa43345cc9c4e293fcaeb5cb1a251bafc27fa177199cf&)

A comprehensive security tool for detecting cheats, exploits, and suspicious system activity. Designed for game administrators.

## Features

- **Exploit Detection**: Identify known cheat software and suspicious files
- **Last Activity Analysis**: Review recent system activity including executed files and opened documents
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
   - **Scan for Exploits**: Scans for known exploits
   - **View Last Activity**: Shows recent system activity
   - **View Reports**: View previously generated reports
   - **Settings**: Configure tool options

## System Requirements
- **OS**: Windows 10/11 (64-bit)  
- **RAM**: 4GB minimum (8GB recommended)  
- **Storage**: 100MB free space  
- **Permissions**: Administrator rights required  
- **Dependencies**: .NET Framework 4.8  

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

CDT includes an automatic update system.

## Support

For issues or feature requests:
- Open an issue on GitHub
- Contact losttroute on Discord

## Contributors
- **Developer**: losttroute  
- **Special Thanks**: sansikw 

## License

MIT License - See [LICENSE]([LICENSE](https://github.com/losttroute/CDT/blob/main/LICENSE.md)) file for details

---

*CDT is provided as-is without warranty. Always verify findings through multiple security tools.*  

*Last Updated: May 2025*
