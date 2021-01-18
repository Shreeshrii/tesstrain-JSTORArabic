# Based on https://github.com/tesseract-ocr/tesstrain/wiki/Arabic-Handwriting

mkdir -p data
cd data
wget https://github.com/tesseract-ocr/langdata_lstm/raw/master/radical-stroke.txt
wget https://github.com/tesseract-ocr/langdata_lstm/raw/master/Latin.unicharset
wget https://github.com/tesseract-ocr/langdata_lstm/raw/master/Arabic.unicharset
# Copy Inherited.unicharset 
cp ~/tesstrain-San/data/Inherited.unicharset ./

git clone https://github.com/OpenITI/TrainingData
mv TrainingData/JSTORArabic JSTORArabic-ground-truth
rm -rf TrainingData

cd JSTORArabic-ground-truth
# Remove images and lines with [a-zA-Z] and other non-Arabic characters
rm -v $(grep -e [a-zA-Z] *.txt|sed s/gt.txt.*$/*/)
rm -v $(grep -e 'ï|è|û|Û|ô|ā|à|ü' *.txt|sed s/gt.txt.*$/*/)
rm -v $(grep -e ש *.txt|sed s/gt.txt.*$/*/)
rm -v $(grep -e ב *.txt|sed s/gt.txt.*$/*/)
rm -v $(grep -e ע *.txt|sed s/gt.txt.*$/*/)

# Remove empty texts (files contain only a line feed) which cannot be used for training.
rm -v $(find . -size 1c|sed s/.gt.txt/.*/)
rm -v $(find . -size 0|sed s/.gt.txt/.*/)

# Remove images and their gt.txt which were written from top to bottom or from bottom to top.
# The heuristics here assumes that such images have a 3 digit width and a 4 digit height.
rm -v $( file *.png|grep ", ... x ....,"|sed s/png/*/)

# Replace Farsi numbers by EAN - This is needed because of wrong transcription.
sed -i -f ../../fixpersiannumbers.sed *.gt.txt

# Replace Western Arabic Numbers by EAN - This is needed because of wrong transcription.
sed -i -f ../../fixwesternnumbers.sed *.gt.txt

# Remove RLM and LRM
sed -i -e 's/‎//g' *.gt.txt
sed -i -e 's/‏//g' *.gt.txt

# REMOVE Non-Arabic LOW FREQ char lines
rm -v $(grep % *.txt|sed s/gt.txt.*$/*/)
rm -v $(grep √ *.txt|sed s/gt.txt.*$/*/)
rm -v $(grep ❊ *.txt|sed s/gt.txt.*$/*/)
rm -v $(grep × *.txt|sed s/gt.txt.*$/*/)
rm -v $(grep — *.txt|sed s/gt.txt.*$/*/)
rm -v $(grep ٪ *.txt|sed s/gt.txt.*$/*/)
rm -v $(grep = *.txt|sed s/gt.txt.*$/*/)
rm -v $(grep ‘ *.txt|sed s/gt.txt.*$/*/)
rm -v $(grep '`' *.txt|sed s/gt.txt.*$/*/)

# Remove space before Arabic Comma
sed -i -e 's/ ،/،/g' *.gt.txt

# Remove old box and lstmf files
rm *.box
rm *.lstmf

cd ../..
rm -rf data/JSTORArabic

#Create unicharset.
nohup make LANG_TYPE=RTL MODEL_NAME=JSTORArabic PSM=13 START_MODEL=ara TESSDATA=$HOME/tessdata_best EPOCHS=100 RATIO_TRAIN=0.80 DEBUG_INTERVAL=-1 unicharset > data/JSTORArabic.log &
tail -f  data/JSTORArabic.log

python count_chars.py data/JSTORArabic/all-gt  | sort -n -r > data/JSTORArabic/all-gt-chars.log
#create_dictdata -i data/JSTORArabic/all-gt -l all-gt -d data/JSTORArabic

nohup make LANG_TYPE=RTL MODEL_NAME=JSTORArabic PSM=13 START_MODEL=ara TESSDATA=$HOME/tessdata_best EPOCHS=100 RATIO_TRAIN=0.80 DEBUG_INTERVAL=-1 lists >> data/JSTORArabic.log &
tail -f  data/JSTORArabic.log
