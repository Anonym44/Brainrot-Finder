# 🎯 Brainrot Finder Pro

A comprehensive Roblox Lua script for automatically scanning and detecting rare animals ("brainrots") and mutations in pet collection games, with Discord webhook notifications and advanced features. Based on the original concept but enhanced with better performance, error handling, and additional features.

## 🌟 Key Features

### Core Functionality
- **Real-time Animal Scanning**: Continuously scans for rare animals in moving containers across multiple game locations
- **Enhanced Mutation Detection**: Identifies special mutations including Gold, Diamond, Rainbow, Candy, Shiny, Crystal, Mystic, Shadow, Light, and Prismatic
- **Player Base Scanning**: Scans player bases, displays, and showcases for rare animals
- **Rich Discord Notifications**: Sends detailed webhook notifications with rich embeds, statistics, and server information
- **Smart Server Hopping**: Automatically switches to optimal servers with intelligent filtering and hop limits

### User Interface & Experience
- **Modern WindUI Interface**: Clean, dark-themed interface with organized tabs and sections
- **Multi-selection Controls**: Easy dropdown selections for target animals and mutations with search functionality
- **Real-time Configuration**: All settings update instantly without requiring script restart
- **Persistent Configuration**: Settings automatically save and load across sessions
- **Synchronized Controls**: Base scanner and main scanner settings stay in sync

### Advanced Features
- **Intelligent Caching**: Time-based caching system prevents spam while allowing re-detection
- **Webhook Retry Logic**: Robust delivery system with exponential backoff and multiple retry attempts
- **Comprehensive Debug Mode**: Detailed console logging for troubleshooting and performance monitoring
- **Audio Notifications**: Different sounds for brainrots vs mutations with volume control
- **Session Statistics**: Real-time tracking of scans performed, items found, and system uptime
- **Performance Optimization**: Configurable scan delays and memory management

## 🚀 Simple Setup Guide

### What You Need First
Before using this script, you need these things:
1. **A Script Executor** - Software that runs scripts in Roblox (like KRNL, Synapse X, Script-Ware, or Fluxus)
2. **A Discord Server** - Where you'll receive notifications when rare pets are found
3. **A Pet Collection Game** - Any Roblox game where you collect/trade pets or animals

### Step-by-Step Installation

**Step 1: Get a Script Executor**
- Download a Roblox script executor (KRNL is free and popular)
- Install it on your computer

**Step 2: Create Discord Webhook**
- Open Discord and go to your server
- Right-click any text channel → "Edit Channel" 
- Click "Integrations" → "Create Webhook"
- Copy the webhook URL (it starts with https://discord.com/api/webhooks/...)

**Step 3: Download the Script**
- Copy all the text from the `brainrot-finder.lua` file in this project

**Step 4: Run the Script**
- Open Roblox and join any pet collection game
- Open your script executor
- Paste the script code into the executor
- Click "Execute" or "Inject"

**Step 5: Configure the Script**
- A window will appear in Roblox with the script interface
- Paste your Discord webhook URL in the "Discord Webhook URL" field
- Click "Test Webhook" to make sure it works (you should get a message in Discord)
- Click "Refresh Animals" to load the pets from your current game
- Select which rare pets you want to hunt for in the dropdown menus
- Turn on "Animal Scanner" to start scanning

### Quick Test
1. Make sure "Animal Scanner" is turned on
2. Select at least one animal type to search for
3. The script will automatically scan and notify you in Discord when it finds rare pets

## ⚙️ Configuration Options

### Main Scanner Settings
- **🎯 Animal Scanner**: Enable real-time scanning of moving animals in the game world
- **✨ Mutation Scanner**: Detect special mutations on any animals found
- **🔄 Refresh Animals**: Reload the list of available animals (use when switching games)
- **🚀 Server Hop**: Manually hop to a new server or enable automatic hopping

### Base Scanner Settings  
- **🏠 Base Scanner**: Scan player bases, displays, and showcases for rare animals
- **✨ Base Mutation Scanner**: Detect mutations in displayed animals
- **🧹 Clear Cache**: Reset found items to allow re-notifications

### Configuration Management
- **💾 Save Configuration**: Save current settings for automatic loading
- **📁 Load Configuration**: Load previously saved settings
- **Server Hop Interval**: Time between automatic server switches (60-600 seconds)
- **🚀 Auto Server Hop**: Enable automatic server hopping for better opportunities
- **🔊 Notification Sound**: Play audio alerts when rare items are found
- **Notification Duration**: How long UI notifications remain visible (3-15 seconds)

### Advanced Settings
- **Scan Delay**: Time between scan cycles - lower values = faster scanning but more CPU usage (0.05-1 seconds)
- **Webhook Retries**: Number of attempts for failed Discord notifications (1-5 retries)
- **🐛 Debug Mode**: Enable detailed console logging for troubleshooting
- **🗑️ Clear All Cache**: Reset all cached data and allow re-detection of previously found items
- **📊 Show Statistics**: Display current session performance metrics

## 🎮 Supported Games

This enhanced script supports a wide range of Roblox pet collection games by automatically detecting multiple folder structures and data formats:

### Automatic Path Detection
- `ReplicatedStorage.Models.Animals` / `ReplicatedStorage.Data.Pets`
- `ReplicatedStorage.Assets.Animals` / `ReplicatedStorage.Config.Pets`
- `ReplicatedStorage.Pets` / `ReplicatedStorage.Animals`
- `Workspace.Pets` / `Workspace.Animals` / `Workspace.MovingAnimals`
- `Workspace.SpawnedPets` / `Workspace.ActiveAnimals`
- `Workspace.Game.Animals` / `Workspace.World.Pets`
- `StarterGui.Assets.Pets`

### Multiple Detection Methods
- **Attributes**: `Index`, `Name`, `PetName`, `AnimalName`, `Mutation`, `Rarity`, `Type`, `Special`
- **StringValues & ObjectValues**: For games storing data in Value objects
- **GUI Elements**: `NameTag`, `DisplayName`, text labels and frames
- **RemoteFunction Integration**: Attempts to call `GetAnimals`/`GetPets` remote functions

### Base Scanning Locations
- Player plots, bases, houses with various naming conventions
- Display podiums, showcases, stands with attachment-based overhead information
- Support for both SurfaceGui and BillboardGui owner detection

## 📱 Enhanced Discord Notifications

Rich webhook embeds include comprehensive information:

### Standard Information
- **🎯 Animal Name**: The specific brainrot/pet found with exact spelling
- **✨ Mutation Type**: Any special mutations detected (Gold, Diamond, etc.)
- **📍 Location**: Container name where the animal was found
- **👥 Owner**: For base scans, displays the base owner's username
- **🎯 Position**: Exact coordinates for moving animals (when available)

### Rich Embed Features
- **📊 Session Statistics**: Real-time scan count, items found, session uptime
- **🕐 Timestamp**: Precise discovery time with timezone information
- **🎯 Server Info**: Shortened server ID for easy identification
- **🔄 Hop Tracking**: Current hop count and session limits

### Color-Coded System
- 🔴 **Red (#ff0000)**: Rare brainrots found in the world
- 🟠 **Orange (#ff6600)**: Brainrots with special mutations
- 🟣 **Purple (#9900ff)**: Mutations found on regular animals
- 🔴 **Dark Red (#ff0000)**: Base brainrots found in player displays
- 🟣 **Dark Purple (#6600ff)**: Base mutations in player displays
- 🟡 **Yellow (#ffaa00)**: Server hop notifications
- 🟢 **Green (#00ff00)**: System messages and tests

### Retry & Reliability
- **Exponential Backoff**: Automatic retry with increasing delays (up to 10 seconds)
- **Multiple Attempts**: Configurable retry count (1-5 attempts)
- **Status Monitoring**: Real-time webhook delivery status with error reporting
- **Graceful Degradation**: UI notifications continue even if webhooks fail

## 🛠️ Troubleshooting Guide

### Common Issues & Solutions

**❌ "No animals found" after clicking Refresh**
- Ensure you're in a supported pet collection game
- Try switching to a different server - some games load animals differently
- Enable 🐛 Debug Mode to see detailed detection logs in console
- Check if the game uses non-standard folder structures (script auto-detects most)

**❌ "Webhook failed" notifications**
- Verify your Discord webhook URL is complete and correct
- Test webhook permissions by clicking "🧪 Test Webhook" 
- Check if your Discord server allows webhook messages
- Ensure webhook URL starts with `https://discord.com/api/webhooks/`

**❌ "Scanner not detecting anything" despite animals being present**
- Verify target animals are selected in the dropdown menus
- Ensure both 🎯 Animal Scanner and ✨ Mutation Scanner toggles are enabled
- Try clearing cache with "🧹 Clear Cache" or "🗑️ Clear All Cache"
- Check if animals are in locations the script scans (moving containers vs static displays)

**❌ Script crashes or stops working**
- Restart the script - it will auto-load your saved configuration
- Check console for error messages if Debug Mode is enabled
- Ensure you're using a compatible script executor
- Try reducing scan frequency with higher "Scan Delay" values

### Debug Mode Features
Enable 🐛 Debug Mode in Advanced settings for detailed console output:
- **Animal Detection**: Shows which containers are being scanned and what's found
- **Webhook Status**: Real-time delivery success/failure with HTTP status codes
- **Server Hop Info**: Details about server selection and hopping attempts
- **Performance Metrics**: Scan counts and processing times
- **Error Details**: Specific error messages for troubleshooting

### Performance Optimization

**For High-End Computers:**
- Set Scan Delay to 0.05-0.1 seconds for maximum speed
- Enable both Animal and Base scanners simultaneously
- Use shorter Server Hop intervals (60-120 seconds)

**For Lower-End Computers:**
- Increase Scan Delay to 0.3-0.5 seconds to reduce CPU usage
- Use only one scanner at a time (Animal OR Base, not both)
- Increase Server Hop interval to 300+ seconds
- Disable notification sounds to save resources

## 📝 Configuration Management

### Automatic Features
- **Auto-save**: Settings save automatically when any control is changed
- **Auto-load**: Configuration loads automatically when script starts (after 2 second delay)
- **Sync**: Main scanner and base scanner settings stay synchronized

### Manual Controls
- **💾 Save Configuration**: Manually save current settings to persistent storage
- **📁 Load Configuration**: Manually reload settings from storage
- **Settings Sync**: Webhook URLs and target selections sync between tabs automatically

### Configuration Data Includes
- Discord webhook URLs and retry settings
- Selected target animals and mutations for both scanners
- Scanner enable/disable states and notification preferences
- Advanced settings like scan delays, hop intervals, and debug mode
- Audio notification settings and UI preferences

## ⚠️ Performance & Safety Notes

### Built-in Protections
- **Rate Limiting**: Configurable scan delays prevent game performance issues
- **Memory Management**: Automatic cache cleanup every 5 minutes prevents memory leaks
- **Hop Limits**: Maximum hops per session (default 10) prevents excessive server switching
- **Webhook Throttling**: Retry logic with exponential backoff prevents Discord rate limiting

### Optimal Usage
- **Single Instance**: Run only one copy of the script per Roblox client
- **Cache Management**: Use "Clear Cache" periodically for best performance
- **Server Selection**: Auto-hop chooses servers with 20-60% capacity for optimal animal spawns
- **Resource Usage**: Monitor CPU usage and adjust scan delays if needed

## 🎯 Advanced Customization

### Adding New Mutations
Edit the `cfg.mutations` table in the script:
```lua
mutations = {"Gold", "Diamond", "Rainbow", "Candy", "Shiny", "Crystal", "Mystic", "Shadow", "Light", "Prismatic", "YourNewMutation"}
```

### Custom Notification Colors
Modify the color values in the scanning functions:
- `0xff0000` = Red for brainrots
- `0x9900ff` = Purple for mutations  
- `0xffaa00` = Yellow for server hops

### Additional Detection Paths
Add new search paths to the `searchPaths` table in the `getBrainrots()` function for games with unique folder structures.

### Webhook Customization
Modify the `sendHook()` function to change embed formatting, add custom fields, or adjust the username and avatar displayed in Discord.

## 📊 Version History & Updates

### Version 2.0 (July 31, 2025) - Enhanced Pro Version
- **Enhanced Animal Detection**: Multiple game support with automatic path detection
- **Rich Discord Notifications**: Detailed embeds with statistics and color coding
- **Intelligent Server Hopping**: Smart server selection with hop limits
- **Advanced Caching**: Time-based system prevents spam while allowing re-detection
- **Performance Optimizations**: Configurable delays and memory management
- **Synchronized UI**: Base and main scanner settings stay in sync
- **Comprehensive Debug Mode**: Detailed logging for troubleshooting

### Version 1.0 (Original GitHub Repository)
- Basic animal scanning with Discord notifications
- Simple server hopping functionality  
- WindUI interface with dropdown selections
- Basic configuration save/load system

## 🎯 Pro Tips for Maximum Efficiency

### Optimal Settings for Different Game Types
**Fast-Paced Games (frequent spawns):**
- Scan Delay: 0.05-0.1 seconds
- Server Hop Interval: 60-120 seconds
- Enable both scanners simultaneously

**Slower Games (rare spawns):**
- Scan Delay: 0.2-0.3 seconds  
- Server Hop Interval: 300-600 seconds
- Focus on base scanning for consistent results

### Best Practices
1. **Start Simple**: Begin with only Animal Scanner enabled and a few target animals
2. **Test First**: Always use "Test Webhook" before starting serious scanning
3. **Monitor Performance**: Watch for lag and adjust scan delays accordingly
4. **Strategic Hopping**: Let auto-hop find optimal servers instead of manual hopping
5. **Cache Management**: Clear cache when switching games or after long sessions

### Target Selection Strategy
- **Quality over Quantity**: Select 3-5 high-value targets rather than everything
- **Mutation Priority**: Focus on Gold, Diamond, Rainbow for best Discord alerts
- **Base vs Moving**: Base scanning catches displayed items, moving scanning catches active spawns

## 📞 Support & Community

### Getting Help
1. **First Steps**: Enable Debug Mode and check console for detailed error messages
2. **Webhook Issues**: Use "Test Webhook" button and verify Discord server permissions
3. **Game Compatibility**: Try "Refresh Animals" in different servers of the same game
4. **Performance Problems**: Adjust scan delays and disable unnecessary features

### Reporting Issues
When reporting problems, please include:
- Game name where issue occurred
- Console output with Debug Mode enabled
- Description of expected vs actual behavior
- Your configuration settings (webhook URL can be redacted)

### Contributing
This script is open for community improvements:
- Submit new game compatibility data
- Report new mutation types discovered
- Suggest UI/UX enhancements  
- Share optimal settings for specific games

## ⚖️ Responsible Usage

### Terms & Guidelines
- **Educational Purpose**: This script is provided for learning about Roblox scripting and automation
- **Respect Game Rules**: Always follow individual game rules and Roblox Terms of Service
- **Fair Play**: Use responsibly without disrupting other players' experiences
- **No Exploitation**: Don't use for unfair advantages that harm game economy or balance

### Ethical Considerations
- **Server Impact**: Script includes rate limiting to prevent server performance issues
- **Community Respect**: Base scanning respects other players' property displays
- **Sharing**: Feel free to share with friends but respect intellectual property

---

## 🎯 Ready to Hunt?

**Your journey to becoming the ultimate brainrot collector starts now!**

1. Copy the `brainrot-finder.lua` script
2. Set up your Discord webhook
3. Configure your target animals and mutations  
4. Enable your preferred scanners
5. Watch the rare finds roll in!

*Happy hunting, and may the RNG be ever in your favor! 🍀*
