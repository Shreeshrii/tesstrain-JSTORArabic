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

# Replace EXTENDED ARABIC-INDIC DIGITs by ARABIC-INDIC DIGITs
for t in *.txt; do sed -i -f ../../fixpersiannumbers.sed $t ; done

# Replace Western DIGITs by ARABIC-INDIC DIGITs
for t in *.txt; do sed -i -f ../../fixwesternnumbers.sed $t ; done

cd ../..
rm -rf data/JSTORArabic

#Create unicharset.
make LANG_TYPE=RTL MODEL_NAME=JSTORArabic PSM=13 START_MODEL=ara TESSDATA=$HOME/tessdata_best MAX_ITERATIONS=9999999 DEBUG_INTERVAL=-1 unicharset

# After above command completes...
# Merge unicharsets.
merge_unicharsets data/JSTORArabic/unicharset fixara.unicharset  data/JSTORArabic/my.unicharset
cp data/JSTORArabic/my.unicharset data/JSTORArabic/unicharset


python count_chars.py data/JSTORArabic/all-gt > data/JSTORArabic/all-gt-chars.log
#create_dictdata -i data/JSTORArabic/all-gt -l all-gt -d data/JSTORArabic
