function getStimStem(elem) {
  return elem.split('.').slice(0, -1).join('.')
};

var fixation = {
  type: 'html-keyboard-response',
  stimulus: '<div style="font-size:60px;">+</div>',
  choices: jsPsych.NO_KEYS,
  trial_duration: 1000 // ms
};

var practice_stimuli = [
  { practice_stimulus: 'img/test1.PNG', data: {test_part: 'practice', correct_response: 32} },
  { practice_stimulus: 'img/test2.PNG', data: {test_part: 'practice', correct_response: null} },
  { practice_stimulus: 'img/test3.PNG', data: {test_part: 'practice', correct_response: null} } ];

var practice_trial = {
  type: 'image-keyboard-response',
  stimulus: jsPsych.timelineVariable('practice_stimulus'),
  choices: [32],
  trial_duration: 1500,  // ms
  data: jsPsych.timelineVariable('data'),
  on_finish: function(data) {
  	if (data.key_press == 32){
  		console.log("KEY PRESSED");
  	};
    data.correct = data.key_press == data.correct_response;
    trial_node_id = jsPsych.currentTimelineNodeID();
  }
};

var practice_feedback = { 
  type: 'html-keyboard-response',
  stimulus: function() {
    var prev_trial = jsPsych.data.getDataByTimelineNode(trial_node_id);
    var prev_trial_correct = prev_trial.select('correct').values[0];
    // Selects name without the .PNG to add overlaid $$$ or bar for reward and neutral
    var prev_trial_stim_file = prev_trial.select('stimulus').values[0];
    var prev_trial_stim = getStimStem(prev_trial_stim_file); 
    var feedback_img = (prev_trial_correct ? prev_trial_stim + '-reward.PNG' : prev_trial_stim + '-neutral.PNG');
    var feedback = prev_trial.select('key_press').values[0];
    // Return the feedback with a border if the subject had 'Go' response/pressed space bar.
    if (feedback == 32) {
    	return '<img src="' + feedback_img + '" border="10px; grey">';
    } else {
    	return '<img src="' + feedback_img + '">';
    }
  },
  choices: jsPsych.NO_KEYS,
  trial_duration: 1000  // ms
};

var practice_block = {
  timeline: [practice_trial, practice_feedback, fixation],
  timeline_variables: practice_stimuli,
  randomize_order: true,
  repetitions: 4
};

var practice_finished = {
  type: 'instructions',
  pages: ['You have completed the practice. Press "Begin" to start the experiment.'],
  show_clickable_nav: true,
  button_label_next: 'Begin'
};

function create_practice() {
  console.log("Creating practice block!");
  return practice_block;
};

function finish_practice() {
  console.log("Finishing practice trials.");
  return practice_finished;
}