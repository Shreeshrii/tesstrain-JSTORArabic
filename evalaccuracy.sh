
MODEL_NAME=JSTORArabic
MODEL_PATH=data/$MODEL_NAME/tessdata_fast
START_MODEL=ara
START_FAST_PATH=$HOME/tessdata_fast
OFFICIAL_MODEL=Arabic
OFFICIAL_FAST_PATH=$HOME/tessdata_fast/script
VALIDATE_LIST=validate
MIN_FAST_MODEL=JSTORArabic_1.057_26227_62100

REPORTS=data/$MODEL_NAME/reports/$VALIDATE_LIST
mkdir -p data/$MODEL_NAME/reports/$VALIDATE_LIST

tesseract -v

cp $OFFICIAL_FAST_PATH/$OFFICIAL_MODEL.traineddata $MODEL_PATH/
cp $START_FAST_PATH/$START_MODEL.traineddata $MODEL_PATH/

rm -rf $REPORTS
mkdir -p $REPORTS

sed -e 's/lstmf/png/' data/$MODEL_NAME/list.$VALIDATE_LIST > data/$MODEL_NAME/list.png.$VALIDATE_LIST
sed -e 's/png/gt.txt/' data/$MODEL_NAME/list.png.$VALIDATE_LIST > data/$MODEL_NAME/list.txt.$VALIDATE_LIST
{ xargs -I{} sh -c "cat {}; echo ''" < data/${MODEL_NAME}/list.txt.$VALIDATE_LIST ; } > $REPORTS/gt.txt


for XXX in $OFFICIAL_MODEL $START_MODEL $MIN_FAST_MODEL ;
do
	OMP_THREAD_LIMIT=1 tesseract data/$MODEL_NAME/list.png.$VALIDATE_LIST $REPORTS/$XXX.OCR -l $XXX --dpi 300 --psm 13 --tessdata-dir $MODEL_PATH -c page_separator=''
	accuracy $REPORTS/gt.txt $REPORTS/$XXX.OCR.txt  $REPORTS/report.$XXX.acc.txt
	wordacc $REPORTS/gt.txt $REPORTS/$XXX.OCR.txt  $REPORTS/report.$XXX.wordacc.txt
	java -cp ~/ocreval.jar eu.digitisation.Main \
		-gt $REPORTS/gt.txt -e UTF-8  \
		-ocr $REPORTS/$XXX.OCR.txt -e UTF-8  \
		-o $REPORTS/report.$XXX.ocrevaluation.html
	OMP_THREAD_LIMIT=1 lstmeval  \
		--verbosity=1 \
		--model data/$MODEL_NAME/tessdata_fast/$XXX.traineddata \
		--eval_listfile data/$MODEL_NAME/list.$VALIDATE_LIST 2>&1 | grep -v ^Loaded | grep -v ^Warning > $REPORTS/$XXX.lstmeval.log.txt
	grep ^OCR $REPORTS/$XXX.lstmeval.log.txt | sed -e 's/^OCR  ://' > $REPORTS/$XXX.lstmeval.OCR.txt
	grep ^Truth $REPORTS/$XXX.lstmeval.log.txt | sed -e 's/^Truth://' > $REPORTS/$XXX.lstmeval.Truth.txt
	wdiff -3 -s  $REPORTS/$XXX.lstmeval.Truth.txt $REPORTS/$XXX.lstmeval.OCR.txt > $REPORTS/report.$XXX.lstmeval.wdiff.txt
	diff -a --suppress-common-lines -y $REPORTS/$XXX.lstmeval.Truth.txt $REPORTS/$XXX.lstmeval.OCR.txt > $REPORTS/report.$XXX.lstmeval.diff.txt
done


