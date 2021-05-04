var instructions_block = {
  type: 'instructions',
  pages: [
    // Welcome (page 1)
    '<p class="center-content">Welcome to the experiment!</p>' +
    '<p class="center-content">You will earn $20 plus a performance-dependent bonus of $0-20 for completing this HIT.</p>' +
    '<p class="center-content">Press "Next" to view the game instructions.</p>',
    // Instructions (page 2)
    '<p class="center-content">The purpose of this experiment is to learn when to press a key in response to colored squares that appear on the screen to obtain monetary reward.</p>' +
    '<p class="center-content">On each screen, you will be shown different colored squares (one at a time). You will need to make a decision to either:</p>' +
    '<p class="center-content">1) <b> PRESS </b> the [spacebar] or 2) <b> NOT PRESS </b> any key in order to obtain a reward ($$$).</p>' +
    '<p class="center-content">You will only see each square for a very short time, so please make a decision as fast as you can!</p>' +
    '<p class="center-content">Here are some example squares you will see during the practice round. You might see different colors during the actual game.</p>' +

    '<table style="margin-left:auto;margin-right:auto;table-layout:fixed !important; width:650px;"><tr>' +
    '<td><img src="img/test1.PNG" style="width: 200px;"></td>' +
    '<td><img src="img/test2.PNG" style="height: 200px; "></td>' +
    '<td><img src="img/test3.PNG" style="height: 200px; "></td>' +
    '</tr><tr>' +
    '<td>Green Square</td><td>Gray Square</td><td>Pink Square</td>' +
    '</tr></table>',
    // Instructions (page 3)
    '<p class="center-content">Each time you see a square, you should decide whether to press [spacebar] or not before the square disappears.</p>' +
    '<p class="center-content">Once the time is up, you will see whether you won money ($$$) or won nothing (-).</p>',
    '<p class="center-content">Your goal is to learn which square(s) you should press [spacebar] for and which square(s) you should not press anything for by paying attention to when you are and are not rewarded.</p>' +
    '<p class="center-content">You will receive a small amount of real bonus money each time you see the dollar signs, and you will be given your bonus after the HIT is approved.</p>' +
    '<p class="center-content">Sometimes, you will receive a reward even if you make the incorrect response, but most of the time, only a correct response will lead to a reward. Not receiving a reward is a neutral outcome and has no effect on your bonus earnings.</p>' +
    '<table style="margin-left:auto;margin-right:auto;table-layout:fixed !important; width:650px;"><tr>' +
    '<td><img src="img/test1-reward.PNG" border="10" style="width: 200px;"></td>' +
    '<td><img src="img/test1-neutral.PNG" style="height: 200px; "></td>' +
    '</tr><tr>' +
    '<td>Reward</td><td>Neutral Result</td>' +
    '</tr> <tr> A black outline indicates you pressed the [spacebar] for that image.</tr></table>',
    //Instructions (page 4)
    '<p class="center-content">This experiment has 4 blocks (not including practice) of 60-120 trials each. We will offer you a break after each block.</p>' +
    '<p class="center-content">The correct action for each colored square may change after each block. For example, if pressing [spacebar] in response to a green square gave you $$$ in the last block, it may no longer give you $$$ in the next block.</p>' +
    '<p class="center-content">So treat each new block as a new task with the same rules.</p>',
    //Instructions (page 5)
    '<p class="center-content">Please try your best to make the best response for each square. We really appreciate your hard work! </p>' +
    '<p class="center-content">Please note that if you respond randomly, always press, or never press, we reserve the right to withold your bonus.</p>',
    // Instructions (page 6)
    '<p class="center-content">We will begin with a practice round to get used to the buttons and timing.</p>' +
    '<p class="center-content">For this round, we will give you the correct answers</p>' +
    '<p class="center-content">Press [spacebar] for the green square, and do not press anything for the gray square or the pink square.</p>' +
    '<p class="center-content">There will be 10 practice trials.</p>' +
    '<p class="center-content">Please remember that you only have a short time to make the decision of whether or not to press [spacebar].</p>' +
    '<table style="margin-left:auto;margin-right:auto;table-layout:fixed !important; width:650px;"><tr>' +
    '<td><img src="img/test1.PNG" style="width: 200px;"></td>' +
    '<td><img src="img/test2.PNG" style="height: 200px; "></td>' +
    '<td><img src="img/test3.PNG" style="height: 200px; "></td>' +
    '</tr><tr>' +
    '<td>Press [spacebar]!</td><td>Do not press!</td><td>Do not press!</td>'+
    '</tr></table>' +
    '<p class="center-content">Please press "Next" to begin the practice.</p>'
  ],
  show_clickable_nav: true,
  allow_backward: true,
  show_page_number: true
};

function create_instructions() {
    console.log("Creating instructions block!");
	return instructions_block;
};