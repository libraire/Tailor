# Tailor
![Image](./logo/image.png)
Tailor is a MacOS screenshot app which will automatically detect rectangle edges and copy with one click.
If no retangles are detected, it switches to selection mode.

# Menu Item Manual
- Capture. Capture the whole screen and detect rectangles. Turn to selection mode if no rectangles detected.
- Selection. Select a rectangle manually.
- Preview Rectangle. Open the largest rectangle with MacOS Preview app for editing.
- Preview Screen. Open the whole screen with Preview app.

# View Demo on Youtube
[![Image](./logo/demo.jpeg)](https://youtu.be/93JuJJTdvsA)


# Current Deficiency
`VNDetectRectanglesRequest` with Swift `Vision` is not accurate in some scenarios. 
I don't have a better solution now. Feel free to provide suggestions. Thank you.
