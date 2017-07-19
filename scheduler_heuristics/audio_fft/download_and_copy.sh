
if [ ! -e input.wav.md5sum ] ; then 
	wget https://www.dropbox.com/s/6big09elmh0qaie/input.wav.md5sum
fi

if [ ! -e input.wav ] ; then 
	wget 
fi 


if [ ! -e $STARPU_PATH_AUDIO_FFT_EXAMPLES/starpu_audio_processing ]; then
       echo "Compile starpu_audio_processing and configure STARPU_PATH_AUDIO_FFT_EXAMPLES";	      exit 1
fi 

md5sum -c input.wav.md5sum
cp input.wav $STARPU_EXAMPLES_DIR/.
cp starpu_audio_processing.sh $STARPU_EXAMPLES_DIR/.
cp $STARPU_PATH_AUDIO_FFT_EXAMPLES/starpu_audio_processing $STARPU_EXAMPLES_DIR/.
