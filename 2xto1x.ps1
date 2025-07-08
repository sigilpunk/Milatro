$path = "C:\Users\matcha\AppData\Roaming\Balatro\Mods\Milatro\assets\1x\Jokers.png"
add-type -AssemblyName System.Drawing
$png = New-Object System.Drawing.Bitmap $path
$scale = "$([math]::Round($($png.Width)/2)):$([math]::Round($($png.Height)/2))"
ffmpeg -i "./assets/1x/Jokers.png" -vf scale=$scale "./assets/2x/Jokers.png"
$png.Dispose()