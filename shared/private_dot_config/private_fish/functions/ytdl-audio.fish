function ytdl-audio --description 'Download audio using yt-dlp via uv'
    if not command -sq uvx
        printf 'ytdl-audio requires uvx (uv).\n' >&2
        return 127
    end
    command uvx yt-dlp -x --remote-components ejs:github $argv
end
