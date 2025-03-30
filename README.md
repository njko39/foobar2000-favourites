# foobar2000-favourites
Add option to favourite songs through SpiderMonkey panel
![image](https://github.com/user-attachments/assets/cf306a56-b433-4090-baff-da248126c455)

# Features:
- Add songs to favourite with ❤️ button 
- Make a playlist of them with ⭐ button

> Favorites are saved by artist and title in \foobar2000\profile\favorites.json file

# IMPORTANT: 
- ⭐ button creating playlist of favourite songs by searching for them in other opened playlists! If a favourited song not opened in any other playlist right now, it will be not added!
- If you renamed song in metadata (not filename or path), you need to manually favourite it again!

# How to install:
1. Install [SpiderMonkey Panel](https://github.com/theqwertiest/foo_spider_monkey_panel) component (make sure your foobar2000 is 32-bit)
2. Go to View > Layout > Enable layout editing mode
3. Add horizontal panel anywhere with right click (Choose Utility > Spider Monkey Panel)
4. Right click new panel > Edit panel script
5. Paste script from [fb2k-favourites.js](https://github.com/njko39/foobar2000-favourites/blob/main/fb2k-favourites.js)
6. Disable layout editing mode

## Alternatively:
You can use sample theme from screenshot above! Download [simple-theme-with-favourites.fth](https://github.com/njko39/foobar2000-favourites/blob/main/simple-theme-with-favourites.fth). After installing SpiderMonkey panel open `File > Preferences > Display > Default User Interface > Import theme` and choose the file you downloaded :>  
