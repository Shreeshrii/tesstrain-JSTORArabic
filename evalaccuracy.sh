LANG=JSTORArabic_1.295_31093_72500
MODEL_NAME=JSTORArabic
##	find $(GROUND_TRUTH_DIR) -name '*.gt.txt' | xargs -I{} sh -c "cat {}; echo ''" > "$@"

sed -e 's/lstmf/png/' data/$MODEL_NAME/list.validate > data/$MODEL_NAME/list.png.validate
sed -e 's/png/gt.txt/' data/$MODEL_NAME/list.png.validate > data/$MODEL_NAME/list.txt.validate
{ xargs -I{} sh -c "cat {}; echo ''" < data/$MODEL_NAME/list.txt.validate ; } > data/$MODEL_NAME/png.gt.txt
## OMP_THREAD_LIMIT=1 tesseract data/$MODEL_NAME/list.png.validate data/$MODEL_NAME/png.OCR -l $LANG --dpi 300 --psm 13 --tessdata-dir data/$MODEL_NAME/tessdata_fast

accuracy data/$MODEL_NAME/png.gt.txt data/$MODEL_NAME/png.OCR.txt  data/$MODEL_NAME/png.$LANG.acc.report.txt
wordacc data/$MODEL_NAME/png.gt.txt data/$MODEL_NAME/png.OCR.txt  data/$MODEL_NAME/png.$LANG.wordacc.report.txt
