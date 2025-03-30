// foobar2000 Spider Monkey Panel script
// Add songs to favourite with ❤️ button 
// Make a plalist of them with ⭐ button
// Favorites are saved by artist and title in favorites.json
// IMPORTANT: ⭐ button create playlist of favourite songs by searching for them in other opened playlist! If a favourited song not opened in any other playlist right now, it will be not added!
// If you renamed song in metadata (not filename or path), you need to manually favourite it again!

const FAVORITES_FILE = "favorites.json";
const FAVORITES_PLAYLIST_NAME = "Favourites";
let favorites = loadFavorites();

function loadFavorites() {
    try {
        const path = `${fb.ProfilePath}${FAVORITES_FILE}`;
        if (utils.FileTest(path, "e")) {
            const raw = utils.ReadTextFile(path);
            return JSON.parse(raw);
        }
    } catch (e) {
        console.log("Failed to load favorites", e);
    }
    return {};
}

function saveFavorites() {
    const path = `${fb.ProfilePath}${FAVORITES_FILE}`;
    try {
        utils.WriteTextFile(path, JSON.stringify(favorites, null, 2));
    } catch (e) {
        console.log("Failed to save favorites", e);
    }
}

function getTrackKey(metadb) {
    if (!metadb) return null;
    const artist = fb.TitleFormat("%artist%").EvalWithMetadb(metadb);
    const title = fb.TitleFormat("%title%").EvalWithMetadb(metadb);
    return `${artist} - ${title}`;
}

function isFavorite(metadb) {
    const key = getTrackKey(metadb);
    return key in favorites;
}

function toggleFavorite(metadb) {
    const key = getTrackKey(metadb);
    if (!key) return;

    if (favorites[key]) {
        delete favorites[key];
    } else {
        favorites[key] = true;
    }

    saveFavorites();
    window.Repaint();
}

function showFavoritesPlaylist() {
    const existing = plman.FindPlaylist(FAVORITES_PLAYLIST_NAME);
    if (existing !== -1) plman.ClearPlaylist(existing);
    const handles = fb.CreateHandleList();
    const plCount = plman.PlaylistCount;

    for (let p = 0; p < plCount; p++) {
        const items = plman.GetPlaylistItems(p);
        for (let i = 0; i < items.Count; i++) {
            const item = items[i];
            if (isFavorite(item)) handles.Add(item);
        }
    }

    let idx = plman.FindPlaylist(FAVORITES_PLAYLIST_NAME);
    if (idx !== -1) plman.RemovePlaylist(idx);
    idx = plman.CreatePlaylist(plman.PlaylistCount, FAVORITES_PLAYLIST_NAME);
    plman.InsertPlaylistItems(idx, 0, handles, false);
    plman.ActivePlaylist = idx;
}

// Button and text placements
let containerRect = { x: 10, y: 10, w: window.Width - 20, h: 40 };
let heartRect = { x: 15, y: containerRect.y + (containerRect.h - 30) / 2 - 3, w: 30, h: 30 };
let songTitleRect = { x: 60, y: containerRect.y, w: window.Width - 250, h: containerRect.h };
let favBtnRect = { x: window.Width - 50, y: containerRect.y + (containerRect.h - 30) / 2 - 3, w: 30, h: 30 };

// Window resize handler
function on_size() {
    // Update button sizes and positions based on new window size
    containerRect.w = window.Width - 20;
    songTitleRect.w = window.Width - 250;
    favBtnRect.x = window.Width - 50;

    // Repaint panel with new sizes
    window.Repaint();
}

function drawHeart(gr, metadb) {
    const fav = isFavorite(metadb);
    const char = fav ? "♥" : "♡";
    const color = fav ? RGB(255, 50, 50) : RGB(180, 180, 180);
    const font = gdi.Font("Segoe UI Symbol", 26);
    gr.DrawString(char, font, color, heartRect.x, heartRect.y, heartRect.w, heartRect.h, 0);
}

function drawSongTitle(gr, metadb) {
    let songTitle = "(No track selected)";
    if (metadb) {
        // Получаем название трека
        songTitle = fb.TitleFormat("%title%").EvalWithMetadb(metadb);
        if (!songTitle || songTitle.trim() === "") {
            songTitle = "(No title)";
        }
    }

    // Font for output
    const font = gdi.Font("Segoe UI", 14);  // Segoe UI font
    const textWidth = gr.MeasureString(songTitle, font, 0, 0, songTitleRect.w, songTitleRect.h).Width;
    const x = songTitleRect.x + (songTitleRect.w - textWidth) / 2;  // Center text (horizontal)
    const y = songTitleRect.y + (songTitleRect.h - 20) / 2;  // Center text (vertical)
    gr.DrawString(songTitle, font, RGB(220, 220, 220), x, y, textWidth, 20); // Print text
}


function drawFavoritesButton(gr) {
    const font = gdi.Font("Segoe UI Symbol", 26);
    gr.DrawString("★", font, RGB(220, 220, 220), favBtnRect.x, favBtnRect.y, favBtnRect.w, favBtnRect.h, 0);
}

function getCurrentTrack() {
    return fb.GetFocusItem();
}

function on_paint(gr) {
    gr.FillSolidRect(0, 0, window.Width, window.Height, RGB(30, 30, 30)); // panel background

    const metadb = getCurrentTrack();
    if (metadb) {
        drawHeart(gr, metadb);
        drawSongTitle(gr, metadb);
    } else {
        gr.DrawString("(No track selected)", gdi.Font("Segoe UI", 14), RGB(150, 150, 150), 20, 20, 300, 30);
    }

    drawFavoritesButton(gr);
}

function on_mouse_lbtn_up(x, y) {
    if (
        x > heartRect.x && x < heartRect.x + heartRect.w &&
        y > heartRect.y && y < heartRect.y + heartRect.h
    ) {
        const metadb = getCurrentTrack();
        if (metadb) toggleFavorite(metadb);
        return;
    }

    if (
        x > favBtnRect.x && x < favBtnRect.x + favBtnRect.w &&
        y > favBtnRect.y && y < favBtnRect.y + favBtnRect.h
    ) {
        showFavoritesPlaylist();
        return;
    }
}

function on_item_focus_change() {
    window.Repaint();
}

function RGB(r, g, b) {
    return (0xff000000 | (r << 16) | (g << 8) | b);
}
