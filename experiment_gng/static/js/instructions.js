var instructions_block = {
  type: 'instructions',
  pages: [
    // Welcome (page 1)
    '<p class="center-content">Welcome to the experiment!</p>' +
    '<p class="center-content">You will earn $2 plus a possible bonus for completing this HIT.</p>' +
    '<p class="center-content">Press "Next" to view the game instructions.</p>',
    // Instructions (page 2)
    '<p class="center-content">You will be shown three different colored squares, one at a time, and you will need to make a decision to either:</p>' +
    '<p class="center-content">1) <b> PRESS </b> the spacebar or 2) <b> NOT PRESS </b> anything.</p>' +
    '<p class="center-content">You will only see each square for a very short time, so please make a decision as fast as you can!</p>' +
    '<p class="center-content">Here are some example squares you will see during the practice. You might see different colors during the actual game.</p>' +

    '<table style="margin-left:auto;margin-right:auto;table-layout:fixed !important; width:650px;"><tr>' +
    '<td><img src="static/img/test1.PNG" style="width: 200px;"></td>' +
    '<td><img src="static/img/test2.PNG" style="height: 200px; "></td>' +
    '<td><img src="static/img/test3.PNG" style="height: 200px; "></td>' +
    '</tr><tr>' +
    '<td>Green Square</td><td>Gray Square</td><td>Pink Square</td>' +
    '</tr></table>',
    // Instructions (page 3)
    '<p class="center-content">Each time you see a square, you should decide whether to press the spacebar or not before the square disappears.</p>' +
    '<p class="center-content">Once the time is up, you will see whether you won money or won nothing.</p>',
    '<p class="center-content">Your goal is to learn which square(s) you should press spacebar for and which square(s) you should not press anything for by paying attention to when you are and are not rewarded.</p>' +
    '<p class="center-content">You will receive a small amount of real bonus money each time you see the dollar signs, and you will be shown your bonus after completing the experiment.</p>' +
    '<p class="center-content">Sometimes, you will receive a reward even if you make the incorrect response, but most of the time, only a correct response will lead to a reward. Not receiving a reward is a neutral outcome and has no effect on your bonus earnings.</p>' +
    '<table style="margin-left:auto;margin-right:auto;table-layout:fixed !important; width:650px;"><tr>' +
    '<td><img src="static/img/test1-reward.PNG" border="10" style="width: 200px;"></td>' +
    '<td><img src="static/img/test1-neutral.PNG" style="height: 200px; "></td>' +
    '</tr><tr>' +
    '<td>Reward</td><td>Neutral Result</td>' +
    '</tr> <tr> A black outline indicates you pressed the space bar for that image.</tr></table>',
    //Instructions (page 4)
    '<p class="center-content">We will offer you a break halfway through the game.</p>' +
    '<p class="center-content">However, please note that nothing will change when you resume the game.</p>' +
    '<p class="center-content">You will see the same colored squares.</p>',
    //Instructions (page 5)
    '<p class="center-content">Please try your best to make the best response for each square. We really appreciate your hard work! </p>' +
    '<p class="center-content">Please note that if you respond randomly, always press, or never press, we reserve the right to withold your bonus.</p>',
    // Instructions (page 6)
    '<p class="center-content">We will begin with a practice to get used to the buttons and timing.</p>' +
    '<p class="center-content">Press spacebar for the green square, and do not press anything for the gray square or the pink square.</p>' +
    '<p class="center-content">There will be 15 practice trials.</p>' +
    '<p class="center-content">Please remember that you only have a short time to make the decision of whether or not to press the spacebar.</p>' +
    '<table style="margin-left:auto;margin-right:auto;table-layout:fixed !important; width:650px;"><tr>' +
    '<td><img src="static/img/test1.PNG" style="width: 200px;"></td>' +
    '<td><img src="static/img/test2.PNG" style="height: 200px; "></td>' +
    '<td><img src="static/img/test3.PNG" style="height: 200px; "></td>' +
    '</tr><tr>' +
    '<td>Press spacebar!</td><td>Do not press!</td><td>Do not press!</td>'+
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