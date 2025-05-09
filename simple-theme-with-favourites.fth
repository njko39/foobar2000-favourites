�����6J�A_s��!   -�p6�,bG��$@��Q�b   Lv?%��Tq���       V   %codec% | %bitrate% kbps | %samplerate% Hz | %channels% | %playback_time%[ / %length%]F��OմLH��.�� JIp  0p�"eU1k�](�Z��       �t�o�@����LQ�9         :��$��O���j���       �      (�7�_tC�l/���Ө   (�7�_tC�l/���Ө;�ӯԆE��N���   ;�ӯԆE��N���bR���.E�'�N���   bR���.E�'�N���fE�G�N�9j�����   fE�G�N�9j����Ƞ����E��@��r�   �����E��@��r�e��B�0�@��jN/+,�   e��B�0�@��jN/+,�|�w�w�E�g<���w           �`wEd�I�������          M{�t��}@��zX�_P           QiDUN�Y���Cci  �Вؠ��^?v�U;"o�   ��rh�J�#�$�N��h  ���.hx�L�w��H�3�nlj�6�O�7d{�]�&�`�NZ�O�ZcKu@���  �-  �$  ���.hx�L�w��H�3���.hx�L�w��H�3�   �  ,  C��%WKI��"��?\脝�o�O��;qϸ�      �        No��	��K��g�>�D^������������    ����TfB���;�_�     D    C��%WKI��"��?       ��C    \脝�o�O��;qϸ�      No��	��K��g�>�D^;����VG������L)�����TG�0��ʵ'   �   Y                         ޾M�o��H����R)t�        9   `       )�I%��H��s��)��        �   `       �����&5H�<P2�3        �  `       IN���PD�8��E��        2   `                   ������������    ����TfB���;�_�      B    ;����VG������L                    �_D    )�����TG�0��ʵ'�          ޾M�o��H����R)t�        9   `       )�I%��H��s��)��        �   `       �����&5H�<P2�3        �  `       IN���PD�8��E��        2   `                   ������������    ����TfB���;�_�     �C    ���.hx�L�w��H�3�   C��%WKI��"��?\脝�o�O��;qϸ�      �        No��	��K��g�>�D^������������    ����TfB���;�_�     D    C��%WKI��"��?       ��C    \脝�o�O��;qϸ�      No��	��K��g�>�D^ ��D    ���.hx�L�w��H�3�  ;����VG������L)�����TG�0��ʵ'   �   Y                         ޾M�o��H����R)t�        9   `       )�I%��H��s��)��        �   `       �����&5H�<P2�3        �  `       IN���PD�8��E��        2   `                   ������������    ����TfB���;�_�      B    ;����VG������L                    �_D    )�����TG�0��ʵ'�          ޾M�o��H����R)t�        9   `       )�I%��H��s��)��        �   `       �����&5H�<P2�3        �  `       IN���PD�8��E��        2   `                       �8��w~@�>*,z	��                                                   {  // foobar2000 Spider Monkey Panel script
// Updated version: displays heart always for the selected track
// Favorites are saved by artist and title in favorites.json
// Added button: open/update "Favourites" playlist

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
}   {
  "edgeStyle": 0,
  "id": "settings",
  "isPseudoTransparent": false,
  "panelId": "{0DB73886-77C8-407E-A23E-2A2C7A09CBE6}",
  "payload": {
    "script": "// foobar2000 Spider Monkey Panel script\r\n// Updated version: displays heart always for the selected track\r\n// Favorites are saved by artist and title in favorites.json\r\n// Added button: open/update \"Favourites\" playlist\r\n\r\nconst FAVORITES_FILE = \"favorites.json\";\r\nconst FAVORITES_PLAYLIST_NAME = \"Favourites\";\r\nlet favorites = loadFavorites();\r\n\r\nfunction loadFavorites() {\r\n    try {\r\n        const path = `${fb.ProfilePath}${FAVORITES_FILE}`;\r\n        if (utils.FileTest(path, \"e\")) {\r\n            const raw = utils.ReadTextFile(path);\r\n            return JSON.parse(raw);\r\n        }\r\n    } catch (e) {\r\n        console.log(\"Failed to load favorites\", e);\r\n    }\r\n    return {};\r\n}\r\n\r\nfunction saveFavorites() {\r\n    const path = `${fb.ProfilePath}${FAVORITES_FILE}`;\r\n    try {\r\n        utils.WriteTextFile(path, JSON.stringify(favorites, null, 2));\r\n    } catch (e) {\r\n        console.log(\"Failed to save favorites\", e);\r\n    }\r\n}\r\n\r\nfunction getTrackKey(metadb) {\r\n    if (!metadb) return null;\r\n    const artist = fb.TitleFormat(\"%artist%\").EvalWithMetadb(metadb);\r\n    const title = fb.TitleFormat(\"%title%\").EvalWithMetadb(metadb);\r\n    return `${artist} - ${title}`;\r\n}\r\n\r\nfunction isFavorite(metadb) {\r\n    const key = getTrackKey(metadb);\r\n    return key in favorites;\r\n}\r\n\r\nfunction toggleFavorite(metadb) {\r\n    const key = getTrackKey(metadb);\r\n    if (!key) return;\r\n\r\n    if (favorites[key]) {\r\n        delete favorites[key];\r\n    } else {\r\n        favorites[key] = true;\r\n    }\r\n\r\n    saveFavorites();\r\n    window.Repaint();\r\n}\r\n\r\nfunction showFavoritesPlaylist() {\r\n    const existing = plman.FindPlaylist(FAVORITES_PLAYLIST_NAME);\r\n    if (existing !== -1) plman.ClearPlaylist(existing);\r\n    const handles = fb.CreateHandleList();\r\n    const plCount = plman.PlaylistCount;\r\n\r\n    for (let p = 0; p < plCount; p++) {\r\n        const items = plman.GetPlaylistItems(p);\r\n        for (let i = 0; i < items.Count; i++) {\r\n            const item = items[i];\r\n            if (isFavorite(item)) handles.Add(item);\r\n        }\r\n    }\r\n\r\n    let idx = plman.FindPlaylist(FAVORITES_PLAYLIST_NAME);\r\n    if (idx !== -1) plman.RemovePlaylist(idx);\r\n    idx = plman.CreatePlaylist(plman.PlaylistCount, FAVORITES_PLAYLIST_NAME);\r\n    plman.InsertPlaylistItems(idx, 0, handles, false);\r\n    plman.ActivePlaylist = idx;\r\n}\r\n\r\n// Button and text placements\r\nlet containerRect = { x: 10, y: 10, w: window.Width - 20, h: 40 };\r\nlet heartRect = { x: 15, y: containerRect.y + (containerRect.h - 30) / 2 - 3, w: 30, h: 30 };\r\nlet songTitleRect = { x: 60, y: containerRect.y, w: window.Width - 250, h: containerRect.h };\r\nlet favBtnRect = { x: window.Width - 50, y: containerRect.y + (containerRect.h - 30) / 2 - 3, w: 30, h: 30 };\r\n\r\n// Window resize handler\r\nfunction on_size() {\r\n    // Update button sizes and positions based on new window size\r\n    containerRect.w = window.Width - 20;\r\n    songTitleRect.w = window.Width - 250;\r\n    favBtnRect.x = window.Width - 50;\r\n\r\n    // Repaint panel with new sizes\r\n    window.Repaint();\r\n}\r\n\r\nfunction drawHeart(gr, metadb) {\r\n    const fav = isFavorite(metadb);\r\n    const char = fav ? \"♥\" : \"♡\";\r\n    const color = fav ? RGB(255, 50, 50) : RGB(180, 180, 180);\r\n    const font = gdi.Font(\"Segoe UI Symbol\", 26);\r\n    gr.DrawString(char, font, color, heartRect.x, heartRect.y, heartRect.w, heartRect.h, 0);\r\n}\r\n\r\nfunction drawSongTitle(gr, metadb) {\r\n    let songTitle = \"(No track selected)\";\r\n    if (metadb) {\r\n        // Получаем название трека\r\n        songTitle = fb.TitleFormat(\"%title%\").EvalWithMetadb(metadb);\r\n        if (!songTitle || songTitle.trim() === \"\") {\r\n            songTitle = \"(No title)\";\r\n        }\r\n    }\r\n\r\n    // Font for output\r\n    const font = gdi.Font(\"Segoe UI\", 14);  // Segoe UI font\r\n    const textWidth = gr.MeasureString(songTitle, font, 0, 0, songTitleRect.w, songTitleRect.h).Width;\r\n    const x = songTitleRect.x + (songTitleRect.w - textWidth) / 2;  // Center text (horizontal)\r\n    const y = songTitleRect.y + (songTitleRect.h - 20) / 2;  // Center text (vertical)\r\n    gr.DrawString(songTitle, font, RGB(220, 220, 220), x, y, textWidth, 20); // Print text\r\n}\r\n\r\n\r\nfunction drawFavoritesButton(gr) {\r\n    const font = gdi.Font(\"Segoe UI Symbol\", 26);\r\n    gr.DrawString(\"★\", font, RGB(220, 220, 220), favBtnRect.x, favBtnRect.y, favBtnRect.w, favBtnRect.h, 0);\r\n}\r\n\r\nfunction getCurrentTrack() {\r\n    return fb.GetFocusItem();\r\n}\r\n\r\nfunction on_paint(gr) {\r\n    gr.FillSolidRect(0, 0, window.Width, window.Height, RGB(30, 30, 30)); // panel background\r\n\r\n    const metadb = getCurrentTrack();\r\n    if (metadb) {\r\n        drawHeart(gr, metadb);\r\n        drawSongTitle(gr, metadb);\r\n    } else {\r\n        gr.DrawString(\"(No track selected)\", gdi.Font(\"Segoe UI\", 14), RGB(150, 150, 150), 20, 20, 300, 30);\r\n    }\r\n\r\n    drawFavoritesButton(gr);\r\n}\r\n\r\nfunction on_mouse_lbtn_up(x, y) {\r\n    if (\r\n        x > heartRect.x && x < heartRect.x + heartRect.w &&\r\n        y > heartRect.y && y < heartRect.y + heartRect.h\r\n    ) {\r\n        const metadb = getCurrentTrack();\r\n        if (metadb) toggleFavorite(metadb);\r\n        return;\r\n    }\r\n\r\n    if (\r\n        x > favBtnRect.x && x < favBtnRect.x + favBtnRect.w &&\r\n        y > favBtnRect.y && y < favBtnRect.y + favBtnRect.h\r\n    ) {\r\n        showFavoritesPlaylist();\r\n        return;\r\n    }\r\n}\r\n\r\nfunction on_item_focus_change() {\r\n    window.Repaint();\r\n}\r\n\r\nfunction RGB(r, g, b) {\r\n    return (0xff000000 | (r << 16) | (g << 8) | b);\r\n}"
  },
  "properties": {
    "id": "properties",
    "values": {},
    "version": "1"
  },
  "scriptType": 1,
  "version": "1"
}������������    ����TfB���;�_�    @hD    �nlj�6�O�7d{�]�&�  ���.hx�L�w��H�3���.hx�L�w��H�3�   �  ,  C��%WKI��"��?\脝�o�O��;qϸ�      �        No��	��K��g�>�D^������������    ����TfB���;�_�     D    C��%WKI��"��?       ��C    \脝�o�O��;qϸ�      No��	��K��g�>�D^;����VG������L)�����TG�0��ʵ'   �   Y                         ޾M�o��H����R)t�        9   `       )�I%��H��s��)��        �   `       �����&5H�<P2�3        �  `       IN���PD�8��E��        2   `                   ������������    ����TfB���;�_�      B    ;����VG������L                    �_D    )�����TG�0��ʵ'�          ޾M�o��H����R)t�        9   `       )�I%��H��s��)��        �   `       �����&5H�<P2�3        �  `       IN���PD�8��E��        2   `                   ������������    ����TfB���;�_�     �C    ���.hx�L�w��H�3�   C��%WKI��"��?\脝�o�O��;qϸ�      �        No��	��K��g�>�D^������������    ����TfB���;�_�     D    C��%WKI��"��?       ��C    \脝�o�O��;qϸ�      No��	��K��g�>�D^ ��D    ���.hx�L�w��H�3�  ;����VG������L)�����TG�0��ʵ'   �   Y                         ޾M�o��H����R)t�        9   `       )�I%��H��s��)��        �   `       �����&5H�<P2�3        �  `       IN���PD�8��E��        2   `                   ������������    ����TfB���;�_�      B    ;����VG������L                    �_D    )�����TG�0��ʵ'�          ޾M�o��H����R)t�        9   `       )�I%��H��s��)��        �   `       �����&5H�<P2�3        �  `       IN���PD�8��E��        2   `                     TB    �`�NZ�O�ZcKu@���-      �8��w~@�>*,z	��                                                   {  // foobar2000 Spider Monkey Panel script
// Updated version: displays heart always for the selected track
// Favorites are saved by artist and title in favorites.json
// Added button: open/update "Favourites" playlist

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
}   {
  "edgeStyle": 0,
  "id": "settings",
  "isPseudoTransparent": false,
  "panelId": "{0DB73886-77C8-407E-A23E-2A2C7A09CBE6}",
  "payload": {
    "script": "// foobar2000 Spider Monkey Panel script\r\n// Updated version: displays heart always for the selected track\r\n// Favorites are saved by artist and title in favorites.json\r\n// Added button: open/update \"Favourites\" playlist\r\n\r\nconst FAVORITES_FILE = \"favorites.json\";\r\nconst FAVORITES_PLAYLIST_NAME = \"Favourites\";\r\nlet favorites = loadFavorites();\r\n\r\nfunction loadFavorites() {\r\n    try {\r\n        const path = `${fb.ProfilePath}${FAVORITES_FILE}`;\r\n        if (utils.FileTest(path, \"e\")) {\r\n            const raw = utils.ReadTextFile(path);\r\n            return JSON.parse(raw);\r\n        }\r\n    } catch (e) {\r\n        console.log(\"Failed to load favorites\", e);\r\n    }\r\n    return {};\r\n}\r\n\r\nfunction saveFavorites() {\r\n    const path = `${fb.ProfilePath}${FAVORITES_FILE}`;\r\n    try {\r\n        utils.WriteTextFile(path, JSON.stringify(favorites, null, 2));\r\n    } catch (e) {\r\n        console.log(\"Failed to save favorites\", e);\r\n    }\r\n}\r\n\r\nfunction getTrackKey(metadb) {\r\n    if (!metadb) return null;\r\n    const artist = fb.TitleFormat(\"%artist%\").EvalWithMetadb(metadb);\r\n    const title = fb.TitleFormat(\"%title%\").EvalWithMetadb(metadb);\r\n    return `${artist} - ${title}`;\r\n}\r\n\r\nfunction isFavorite(metadb) {\r\n    const key = getTrackKey(metadb);\r\n    return key in favorites;\r\n}\r\n\r\nfunction toggleFavorite(metadb) {\r\n    const key = getTrackKey(metadb);\r\n    if (!key) return;\r\n\r\n    if (favorites[key]) {\r\n        delete favorites[key];\r\n    } else {\r\n        favorites[key] = true;\r\n    }\r\n\r\n    saveFavorites();\r\n    window.Repaint();\r\n}\r\n\r\nfunction showFavoritesPlaylist() {\r\n    const existing = plman.FindPlaylist(FAVORITES_PLAYLIST_NAME);\r\n    if (existing !== -1) plman.ClearPlaylist(existing);\r\n    const handles = fb.CreateHandleList();\r\n    const plCount = plman.PlaylistCount;\r\n\r\n    for (let p = 0; p < plCount; p++) {\r\n        const items = plman.GetPlaylistItems(p);\r\n        for (let i = 0; i < items.Count; i++) {\r\n            const item = items[i];\r\n            if (isFavorite(item)) handles.Add(item);\r\n        }\r\n    }\r\n\r\n    let idx = plman.FindPlaylist(FAVORITES_PLAYLIST_NAME);\r\n    if (idx !== -1) plman.RemovePlaylist(idx);\r\n    idx = plman.CreatePlaylist(plman.PlaylistCount, FAVORITES_PLAYLIST_NAME);\r\n    plman.InsertPlaylistItems(idx, 0, handles, false);\r\n    plman.ActivePlaylist = idx;\r\n}\r\n\r\n// Button and text placements\r\nlet containerRect = { x: 10, y: 10, w: window.Width - 20, h: 40 };\r\nlet heartRect = { x: 15, y: containerRect.y + (containerRect.h - 30) / 2 - 3, w: 30, h: 30 };\r\nlet songTitleRect = { x: 60, y: containerRect.y, w: window.Width - 250, h: containerRect.h };\r\nlet favBtnRect = { x: window.Width - 50, y: containerRect.y + (containerRect.h - 30) / 2 - 3, w: 30, h: 30 };\r\n\r\n// Window resize handler\r\nfunction on_size() {\r\n    // Update button sizes and positions based on new window size\r\n    containerRect.w = window.Width - 20;\r\n    songTitleRect.w = window.Width - 250;\r\n    favBtnRect.x = window.Width - 50;\r\n\r\n    // Repaint panel with new sizes\r\n    window.Repaint();\r\n}\r\n\r\nfunction drawHeart(gr, metadb) {\r\n    const fav = isFavorite(metadb);\r\n    const char = fav ? \"♥\" : \"♡\";\r\n    const color = fav ? RGB(255, 50, 50) : RGB(180, 180, 180);\r\n    const font = gdi.Font(\"Segoe UI Symbol\", 26);\r\n    gr.DrawString(char, font, color, heartRect.x, heartRect.y, heartRect.w, heartRect.h, 0);\r\n}\r\n\r\nfunction drawSongTitle(gr, metadb) {\r\n    let songTitle = \"(No track selected)\";\r\n    if (metadb) {\r\n        // Получаем название трека\r\n        songTitle = fb.TitleFormat(\"%title%\").EvalWithMetadb(metadb);\r\n        if (!songTitle || songTitle.trim() === \"\") {\r\n            songTitle = \"(No title)\";\r\n        }\r\n    }\r\n\r\n    // Font for output\r\n    const font = gdi.Font(\"Segoe UI\", 14);  // Segoe UI font\r\n    const textWidth = gr.MeasureString(songTitle, font, 0, 0, songTitleRect.w, songTitleRect.h).Width;\r\n    const x = songTitleRect.x + (songTitleRect.w - textWidth) / 2;  // Center text (horizontal)\r\n    const y = songTitleRect.y + (songTitleRect.h - 20) / 2;  // Center text (vertical)\r\n    gr.DrawString(songTitle, font, RGB(220, 220, 220), x, y, textWidth, 20); // Print text\r\n}\r\n\r\n\r\nfunction drawFavoritesButton(gr) {\r\n    const font = gdi.Font(\"Segoe UI Symbol\", 26);\r\n    gr.DrawString(\"★\", font, RGB(220, 220, 220), favBtnRect.x, favBtnRect.y, favBtnRect.w, favBtnRect.h, 0);\r\n}\r\n\r\nfunction getCurrentTrack() {\r\n    return fb.GetFocusItem();\r\n}\r\n\r\nfunction on_paint(gr) {\r\n    gr.FillSolidRect(0, 0, window.Width, window.Height, RGB(30, 30, 30)); // panel background\r\n\r\n    const metadb = getCurrentTrack();\r\n    if (metadb) {\r\n        drawHeart(gr, metadb);\r\n        drawSongTitle(gr, metadb);\r\n    } else {\r\n        gr.DrawString(\"(No track selected)\", gdi.Font(\"Segoe UI\", 14), RGB(150, 150, 150), 20, 20, 300, 30);\r\n    }\r\n\r\n    drawFavoritesButton(gr);\r\n}\r\n\r\nfunction on_mouse_lbtn_up(x, y) {\r\n    if (\r\n        x > heartRect.x && x < heartRect.x + heartRect.w &&\r\n        y > heartRect.y && y < heartRect.y + heartRect.h\r\n    ) {\r\n        const metadb = getCurrentTrack();\r\n        if (metadb) toggleFavorite(metadb);\r\n        return;\r\n    }\r\n\r\n    if (\r\n        x > favBtnRect.x && x < favBtnRect.x + favBtnRect.w &&\r\n        y > favBtnRect.y && y < favBtnRect.y + favBtnRect.h\r\n    ) {\r\n        showFavoritesPlaylist();\r\n        return;\r\n    }\r\n}\r\n\r\nfunction on_item_focus_change() {\r\n    window.Repaint();\r\n}\r\n\r\nfunction RGB(r, g, b) {\r\n    return (0xff000000 | (r << 16) | (g << 8) | b);\r\n}"
  },
  "properties": {
    "id": "properties",
    "values": {},
    "version": "1"
  },
  "scriptType": 1,
  "version": "1"
}����B��%gq��/     ;����VG������L   Playlist Tabs���.hx�L�w��H�3   Splitter (top/bottom)                   Empty UI Element)�����TG�0��ʵ'   Playlist ViewC��%WKI��"��?   Selection Properties\脝�o�O��;qϸ�   Album Art Viewer�nlj�6�O�7d{�]�&   Splitter (left/right)�`�NZ�O�ZcKu@��   Spider Monkey PanelW��w/�@�MR}at*   ����C)w2�-���rb    ��Y���H���[�b-T   ��ڞM���68   ��]��oA�-��1���   ��@���C�;�2n5����B���j>:B�fe��u� f̀k���
~�F����@� x׀