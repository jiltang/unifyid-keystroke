# unifyid-keystroke
Coding challenge for UnifyID

## Instructions

## Description
`read_data.R` makes raw and processed data from the JSON files. This computes qualified users as well as creates some features based on timing and error rates.

I originally tried to train models on the long datasets, with a matrix for each entry containing all the keystrokes and some additional data. My plan was to use a GRU to create the predictions, as the data is clearly time-correlated. However, this proved to be too slow to train, so I reshaped the data, limiting it to 40 keystrokes. I tried a neural network on this, along with a random forest, which got __ accuracy.

## Additional Questions
* If you had one additional day, what would you change or improve to your submission?
I would work on improving the approach neural network – with more training time, I could use larger networks and more complicated architectures. One thing I would have liked to try was using a GRU on the

* How would you modify your solution if the number of users was 1,000 times larger?
* What insights and takeaways do you have on the distribution of user performance?
* What aspect(s) would you change about this challenge?
* What aspect(s) did you enjoy about this challenge?
