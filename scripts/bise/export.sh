# --- Tailscale ---

# Auth key used to register bise on the tailnet.
# Generate one at https://login.tailscale.com/admin/settings/keys
export TAILSCALE_KEY="tskey-auth-kQZRMdCfCC11CNTRL-Yd4cZRGBcEFTZTow4njSEFfAw3d9Q9GJ"

# --- Transmission ---

export TRANSMISSION_RPC_PASSWORD="{19fbc2a0a7ff0a3d041aeb3c1936c0a77c23bff0/IraM0Fj"

# --- Navidrome ---

export SPOTIFY_ID="6601e3629f3445f68cba6a1df3482d88"
export SPOTIFY_SECRET="28cb859627574e669185cd78b54b566a"

export LASTFM_APIKEY="35d0fdf8681279ecc6b15cbb61ae2f7b"
export LASTFM_SECRET="8b7ec4b483d65affa62b86f4b59f9be8"

# --- Icecast (radio role) ---

# Password liquidsoap uses to push the audio stream to icecast.
# Must match the <source-password> in icecast.xml.
export ICECAST_SOURCE_PASSWORD="193a3d5d4d1430e20f4860bc"

# Password used by icecast relay nodes to pull the stream.
# Not needed unless you set up a relay; still required by icecast.
export ICECAST_RELAY_PASSWORD="82c3de0cad55822dcbb7d588"

# Password for the icecast web admin interface (port 8000/admin).
export ICECAST_ADMIN_PASSWORD="c8a08d652ff366259718fe1a"
