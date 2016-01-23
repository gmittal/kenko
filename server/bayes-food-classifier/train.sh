#!/bin/bash
# Requires jq
# brew install jq
# Food training script

NUM_FOOD_LABELS=$(expr $(sed -n '$=' training_data/imagenet.food\[food\].txt) + $(sed -n '$=' training_data/imagenet.drink\[food\].txt))
NUM_NON_FOOD_LABELS=$(sed -n '$=' training_data/imagenet.urban\[not-food\].txt)
TOTAL_LABELS=$(expr $NUM_FOOD_LABELS + $NUM_NON_FOOD_LABELS)
LABELS_COMPLETE=0
echo "NUM_FOOD_LABELS: " $NUM_FOOD_LABELS
echo "NUM_NON_FOOD_LABELS: " $NUM_NON_FOOD_LABELS
echo "[" >> train.json

# Run all 'food' labeled imagenet stuff through
for line in $(cat training_data/imagenet.food\[food\].txt); do
    PERCENT_COMPLETE=$(echo "scale = 1; $LABELS_COMPLETE * 100 / $TOTAL_LABELS" | bc)
    echo "["$PERCENT_COMPLETE"%]" $line # or whaterver you want to do with the $line variable
    resultCloud=$(phantomjs visualize.js $line)
    LABELS_COMPLETE=$(expr $LABELS_COMPLETE + 1)
    if [[ $resultCloud != *"Error: 400 Bad Request"* ]]
    then
      verifiedJSON=$(echo $resultCloud | jq ".name")
      echo "{'text': $verifiedJSON, 'label': 'food'}" >> train.json
    fi
done

for line in $(cat training_data/imagenet.drink\[food\].txt); do
    PERCENT_COMPLETE=$(echo "scale = 1; $LABELS_COMPLETE * 100 / $TOTAL_LABELS" | bc)
    echo "["$PERCENT_COMPLETE"%]" $line # or whaterver you want to do with the $line variable
    resultCloud=$(phantomjs visualize.js $line)
    LABELS_COMPLETE=$(expr $LABELS_COMPLETE + 1)
    if [[ $resultCloud != *"Error: 400 Bad Request"* ]]
    then
      verifiedJSON=$(echo $resultCloud | jq ".name")
      echo "{'text': $verifiedJSON, 'label': 'food'}" >> train.json
    fi
done

#Run all 'not food' labeled imagenet stuff
for line in $(cat training_data/imagenet.urban\[not-food\].txt); do
    PERCENT_COMPLETE=$(echo "scale = 1; $LABELS_COMPLETE * 100 / $TOTAL_LABELS" | bc)
    echo "["$PERCENT_COMPLETE"%]" $line # or whaterver you want to do with the $line variable
    resultCloud=$(phantomjs visualize.js $line)
    LABELS_COMPLETE=$(expr $LABELS_COMPLETE + 1)
    if [[ $resultCloud != *"Error: 400 Bad Request"* ]]
    then
      verifiedJSON=$(echo $resultCloud | jq ".name")
      echo "{'text': $verifiedJSON, 'label': 'not food'}" >> train.json
    fi
done

for line in $(cat training_data/imagenet.people\[not-food\].txt); do
    PERCENT_COMPLETE=$(echo "scale = 1; $LABELS_COMPLETE * 100 / $TOTAL_LABELS" | bc)
    echo "["$PERCENT_COMPLETE"%]" $line # or whaterver you want to do with the $line variable
    resultCloud=$(phantomjs visualize.js $line)
    LABELS_COMPLETE=$(expr $LABELS_COMPLETE + 1)
    if [[ $resultCloud != *"Error: 400 Bad Request"* ]]
    then
      verifiedJSON=$(echo $resultCloud | jq ".name")
      echo "{'text': $verifiedJSON, 'label': 'not food'}" >> train.json
    fi
done

echo "]" >> train.json
