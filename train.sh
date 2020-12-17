
# Create box and lstmf files and then the lists of lstmf files for training and validation.
# This will take a while.
# Do training.
nohup make LANG_TYPE=RTL MODEL_NAME=JSTORArabic PSM=13 START_MODEL=ara TESSDATA=$HOME/tessdata_best MAX_ITERATIONS=9999999 DEBUG_INTERVAL=-1 training >> data/JSTORArabic.log &
