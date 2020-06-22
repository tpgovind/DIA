To detect onset of escape in an automated fashion from tail-suspension trials and looming-shadow recordings, we applied frame-to-frame image differencing to segment regions of the scene exhibiting movement. This approach works well for analyzing stable recordings where the background is unchanging (e.g. fixed home-cage) and there is large movement in the foreground (e.g. animal locomotion). A custom ImageJ macro and sample images are provided to illustrate difference-image-analysis. As well, a custom MATLAB script and sample data are provided for detecting onset and offset of movement. See here: https://github.com/tpgovind/DIA

To prepare the camera data for onset detection, we used the following algorithm to perform pixel-by-pixel frame subtraction in ImageJ:
  1.Import raw behavioral video as a stack of n 8-bit grayscale images.
  2.Duplicate the stack and rename the first as ‘Stack1’ and the second as ‘Stack2’.
  3.Delete the first frame of ‘Stack1’ and the last frame of ‘Stack2’. Thus, each stack now has n-1 frames, and ‘Stack1’ leads ‘Stack2’ by a single frame.
  4.Subtract every pixel from each image of ‘Stack2’ from the corresponding pixel in ‘Stack1’ with 8-bit precision.
  5.Enhance contrast and smooth (as appropriate) and save the resulting image.
  6.Compute the mean gray value of each image in the resulting stack and plot mean gray value against time (frame number divided by sampling rate). Save data in a file format set by MATLAB script requirements (see 'sample_data.xlsx').

To detect movement onset, we used a custom MATLAB script (see 'detectEscape.m'). In our experience, four times median absolute deviation from baseline is a reliable indicator of an escape movement.
