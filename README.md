# unifyid-keystroke
Coding challenge for UnifyID

## Instructions
1. Install R dependencies: jsonlite, data.table, plyr, dplyr, randomForest
2. To make predictions, run `./run.sh URL` (replacing URL with the URL of the JSON file for which to get predictions).
3. Predictions will be outputted in `predictions.csv`. If the entry is invalid, there will be no prediction outputted for that entry.

## Description
`read_data.R` makes raw and processed data from the JSON files. This computes qualified users as well as creates some features based on timing and error rates.

I originally tried to train models on the long datasets, with a matrix for each entry containing all the keystrokes and some additional data. My plan was to use a GRU to create the predictions, as the data is clearly time-correlated. However, this proved to be too slow to train, so I reshaped the data, limiting it to 40 keystrokes. I tried a neural network on this, along with a random forest, which got 74% accuracy.

Accuracies per user:
[1] "accuracy for user 1: 0.739393939393939"
[1] "accuracy for user 2: 0.739944903581267"
[1] "accuracy for user 3: 0.739944903581267"
[1] "accuracy for user 4: 0.739393939393939"
[1] "accuracy for user 5: 0.740495867768595"
[1] "accuracy for user 6: 0.739944903581267"
[1] "accuracy for user 7: 0.740495867768595"
[1] "accuracy for user 8: 0.740495867768595"
[1] "accuracy for user 9: 0.741046831955923"
[1] "accuracy for user 10: 0.740495867768595"
[1] "accuracy for user 11: 0.739944903581267"
[1] "accuracy for user 12: 0.739944903581267"
[1] "accuracy for user 13: 0.740495867768595"
[1] "accuracy for user 14: 0.739944903581267"
[1] "accuracy for user 15: 0.740495867768595"
[1] "accuracy for user 16: 0.739944903581267"
[1] "accuracy for user 17: 0.739393939393939"
[1] "accuracy for user 18: 0.740495867768595"
[1] "accuracy for user 19: 0.740495867768595"
[1] "accuracy for user 20: 0.740495867768595"
[1] "accuracy for user 21: 0.741046831955923"
[1] "accuracy for user 22: 0.740495867768595"
[1] "accuracy for user 23: 0.739393939393939"
[1] "accuracy for user 24: 0.740495867768595"
[1] "accuracy for user 25: 0.738842975206612"

## Additional Questions
* *If you had one additional day, what would you change or improve to your submission?*
I would work on improving the approach neural network – with more training time, I could use larger networks and more complicated architectures. One thing I would have liked to try was using a GRU on the data – I attempted to implement this but did not have time to train it.

* *How would you modify your solution if the number of users was 1,000 times larger?*
In this case, I might write the pipeline in a lower-level language so that it could process the data faster or be incorporated more easily into whatever framework the data engineers have set up.

* *What insights and takeaways do you have on the distribution of user performance?*
The accuracy for each user is pretty uniform.

* *What aspect(s) would you change about this challenge?*
It'd be nice if everything weren't piped through JSON files where the next JSON file location comes from the current one.

* *What aspect(s) did you enjoy about this challenge?*
This was a lot of fun! I really enjoyed the challenges of working with keystroke data.
