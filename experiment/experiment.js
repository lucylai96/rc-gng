// Policy Complexity as Set Size in Go/NoGo Task
// Previous Work By Hayley Dorfman
// Updated June 2020 by Emma Rogge for Lucy Lai's experiment

// Create reward probability functions for 4 stimuli
  var control = [[0.8, 0.2],[0.2, 0.8]]; // control (go, no-go)
  var hs_lc = [[0.6, 0.4],[0.4, 0.6],[0.6, 0.4],[0.4, 0.6]]; // high similarity, low control
  var hs_hc = [[0.8, 0.2],[0.2, 0.8],[0.8, 0.2],[0.2, 0.8]]; // high similarity, high control
  var ls_lc = [[0.8, 0.2],[0.2, 0.8],[0.6, 0.4],[0.4, 0.6]]; // low similarity, low control
  var ls_hc = [[0.8, 0.2],[0.2, 0.8],[1, 0], [0, 1]]; // low similarity, high control
  var conditions = [control, hs_lc, hs_hc, ls_lc, ls_hc];


  var num_trials_per_stim = 30;
  var num_blocks = conditions.length;
  var num_stim = conditions.length*4 - 2;
  var n_trials = num_trials_per_stim*num_stim;
  console.log(n_trials)


// Feedback functions
function getStimStem(elem) {
  return String(elem.substring(0, elem.length - 4));
};

function getReward(elem) {
  return elem + '-r.png'
};

function getNeutral(elem) {
  return elem + '-n.png'
};

function getOutcome(elem) {
  var outcome = (elem.indexOf('reward') !== -1 ? 1 : 0);
  return outcome
};

/* Given the previous trial stimulus, correctness of subject response and reward context, returns either reward or neutral feedback. */
function getStochasticOutcome(stim, feedback, reward_context) {
  if (feedback == 32){
      var action = 0; //go
    }else {
  var action = 1; //no-go
}
var R = Math.random();
if (R < reward_context[0][action]) {
  reward = 1;
  return [getReward(stim), reward];
} else {
  reward = 0;
  return [getNeutral(stim), reward];
}
};

/* Save data to CSV  */
function saveData(name, data) {
  var xhr = new XMLHttpRequest();
    xhr.open('POST', 'write_data.php'); // 'write_data.php' is the path to the php file described above.
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send(JSON.stringify({
      filename: name,
      filedata: data
    }));
  }

// Stimuli
  var stimuli = [
  "img/blue.png",
  "img/red.png",
  "img/green.png",
  "img/grey.png",
  "img/purple.png",
  "img/pink.png",
  "img/yellow.png",
  "img/orange.png"
  ];

  var timeline = [];

  /* Obtain consent */
  var consent_block = create_consent();
  timeline.push(consent_block);

  /* Instructions */
  var instructions_block = create_instructions(timeline);
  timeline.push(instructions_block);

  /* Practice */
  var practice_block = create_practice();
  var finish_practice = finish_practice();
  timeline.push(practice_block);
  timeline.push(finish_practice);

  // Variable to keep track of most recent trial (to compare correctness)
  var trial_node_id = '';

  // Block 1
  var trial = {
    type: 'image-keyboard-response',
    stimulus: jsPsych.timelineVariable('stimulus'),
    choices: [32],
    trial_duration: 1500,  // ms
    data: jsPsych.timelineVariable('data'),
    on_finish: function(data) {
      data.correct = data.key_press == data.correct_response;
      trial_node_id = jsPsych.currentTimelineNodeID();
      var curr_progress_bar_value = jsPsych.getProgressBarCompleted();
      jsPsych.setProgressBar(curr_progress_bar_value + (1/n_trials));
    }
  };

  var feedback = {
    type: 'html-keyboard-response',
    data: jsPsych.timelineVariable('data'),
    stimulus: function() {
      var prev_trial = jsPsych.data.getDataByTimelineNode(trial_node_id);
      var prev_trial_correct = prev_trial.select('correct').values[0];
      var prev_trial_stim = getStimStem(prev_trial.select('stimulus').values[0]);
      // Select the reward probability function for given stimulus.
      var stim_reward_context = prev_trial.select('use_rew').values;
      var feedback = prev_trial.select('key_press').values[0];
      console.log(stim_reward_context)
      var [outcome, reward] = getStochasticOutcome(prev_trial_stim, feedback, stim_reward_context);
      console.log(reward)
      // Return the feedback with a border if the subject had 'Go' response/pressed space bar.
      if (feedback == 32) {
        console.log("OUTCOME: " + JSON.stringify(outcome));
        return '<img src="' + outcome + '" border="10">';
      } else {
        return '<img src="' + outcome + '">';
      }
    },
    choices: jsPsych.NO_KEYS,
    trial_duration: 1000,  // ms
    on_finish: function(data) {
      fb_node_id = jsPsych.currentTimelineNodeID();
      var feedback_data = jsPsych.data.getDataByTimelineNode(fb_node_id);
      var fb_full = feedback_data.select('stimulus').values[0];
      var feedback_num = getOutcome(fb_full);
      //jsPsych.data.get().addToLast({feedback_num: feedback_num});
      jsPsych.data.get().addToLast({reward: reward});
    }
  };

  var fixation = {
    type: 'html-keyboard-response',
    stimulus: '<div style="font-size:60px;">+</div>',
    choices: jsPsych.NO_KEYS,
    trial_duration: 1000 // ms
  };


  var between_block = {
    type: 'instructions',
    pages: [
    '<p class="center-content">You have completed a block!</p> Take a break if you would like and then press "Next" to continue.</p>'
    ],
    show_clickable_nav: true
  };
  console.log("About to shuffle blocks!");

// for CONTROL condition
var shuffled_stimuli = jsPsych.randomization.repeat(stimuli, 1);
var go_stimulus_a = shuffled_stimuli[0];
var nogo_stimulus_b = shuffled_stimuli[1];
var reward_prob  = conditions[0]
var reward_prob_a = reward_prob[0];
var reward_prob_b = reward_prob[1];

var control_block_stim = [];
control_block_stim.push(
  [ { stimulus: go_stimulus_a,
    data: { test_part: 'trial', correct_response: 32, 
    use_rew: reward_prob_a, which_stim: '1:go_a'} },
    { stimulus: nogo_stimulus_b,
      data: { test_part: 'trial', correct_response: null, 
      use_rew: reward_prob_b, which_stim: '2:nogo_b'} }
      ] 
      );

var control_block = {
  timeline: [trial, feedback, fixation],
  timeline_variables: control_block_stim[0],
  randomize_order: true,
  repetitions: num_trials_per_stim
};

console.log("Control block");
timeline.push(control_block);
timeline.push(between_block);

// other conditions order
var order = [1,2,3,4]
var order = jsPsych.randomization.repeat(order, 1);

for (i = 0; i < order.length; i++) {
      var block = order[i]; // randomized block order
      var reward_prob  = conditions[block]
      var reward_prob_a = reward_prob[0];
      var reward_prob_b = reward_prob[1];
      var reward_prob_c = reward_prob[2];
      var reward_prob_d = reward_prob[3];
      console.log(reward_prob);

      // Shuffle Stimuli Ordering -- shuffle on every block
      var shuffled_stimuli = jsPsych.randomization.repeat(stimuli, 1);
      console.log(shuffled_stimuli)
      // Initialize stimuli for two go and two nogo reward contexts
      var go_stimulus_a = shuffled_stimuli[0];
      var nogo_stimulus_b = shuffled_stimuli[1];
      var go_stimulus_c = shuffled_stimuli[2];
      var nogo_stimulus_d = shuffled_stimuli[3];


      // Initialize stimuli 
      var block_stim = [];
      block_stim.push(
        [ { stimulus: go_stimulus_a,
          data: { test_part: 'trial', correct_response: 32, 
          use_rew: reward_prob_a, which_stim: '1:go_a' } },

          { stimulus: nogo_stimulus_b,
            data: { test_part: 'trial', correct_response: null, 
            use_rew: reward_prob_b, which_stim: '2:nogo_b' } },

            { stimulus: go_stimulus_c,
              data: { test_part: 'trial', correct_response: 32, 
              use_rew: reward_prob_c, which_stim: '3:go_c' } },

              { stimulus: nogo_stimulus_d,
                data: { test_part: 'trial', correct_response: null, 
                use_rew: reward_prob_d, which_stim: '4:nogo_d'} }        
                ] 
                );

      var block = {
        timeline: [trial, feedback, fixation],
        timeline_variables: block_stim[0],
        randomize_order: true,
        repetitions: num_trials_per_stim
      };

      timeline.push(block);
      timeline.push(between_block);

    }



  // Calculate bonus at end
  var bonus_block = {
    type: 'instructions',
    pages: function() {
      var correct_bonus = Math.round(100 * jsPsych.data.get().filter({correct: true}).count() / (num_blocks * 2 * num_trials_per_stim)); //
      jsPsych.data.addDataToLastTrial({"bonus": correct_bonus});
      return ['<p class="center-content">You won a bonus of <b>$' + (correct_bonus == 100 ? '1.00' : '0.' + correct_bonus) + '</b>.</p>' +
      '<p class="center-content"> IMPORTANT: <b>Press "Next"</b> to continue to the survey questions.</p>'];
    },
    show_clickable_nav: true
  };
  //timeline.push(bonus_block);

  var survey_comments = {
    type: 'survey-text',
    questions: [{prompt: 'You have finished the experiment! We\'re always trying to improve. Please let us know if you have any feedback or comments about the task.', value: 'Comments'}],
    button_label: 'Submit'
  };
  timeline.push(survey_comments);

  // Save data=
  var save_data = {
    type: "survey-text",
    questions: [{prompt: 'Please input your MTurk Worker ID so that we can pay you the appropriate bonus. Your ID will not be shared with anyone outside of our research team. Your data will now be saved.', value: 'Worker ID'}],
    on_finish: function(data) {
      var responses = JSON.parse(data.responses);
      var subject_id = responses.Q0;
      console.log(subject_id)
      saveData(subject_id, jsPsych.data.get().csv());;
    },
  }

  timeline.push(save_data);

  var end_block = {
    type: 'instructions',
    pages: [
    '<p class="center-content"> <b>Thank you for participating in our experiment!</b></p>' +
    '<p class="center-content"> <b>Please wait on this page for a minute while your data saves.</b></p>'+
    '<p class="center-content"> Your bonus will be applied after your data has been processed and your HIT has been approved.</p>'+
    '<p class="center-content"> Please email lucylai@g.harvard.edu with any additional questions or concerns. You may now exit this window.</p>'
    ],
    show_clickable_nav: false,
    allow_backward: false,
    show_page_number: false
  };
  timeline.push(end_block);

  function startExperiment(){
    console.log("Timeline: " + JSON.stringify(timeline));
    jsPsych.init({
      timeline: timeline,
      show_progress_bar: true,
      auto_update_progress_bar: false,
      //on_finish: function() {
        //window.location.href = "end.html";
      //}
    })
  };

  images = ['img/blue-r.png', 'img/red-r.png', 'img/green-r.png', 'img/grey-r.png', 'img/purple-r.png', 'img/pink-r.png', 'img/yellow-r.png', 'img/orange-r.png','img/blue-n.png', 'img/red-n.png', 'img/green-n.png', 'img/grey-n.png', 'img/purple-n.png', 'img/pink-n.png', 'img/yellow-n.png', 'img/orange-n.png','img/test1.PNG', 'img/test1-reward.PNG', 'img/test1-neutral.PNG', 'img/test2.PNG', 'img/test2-reward.PNG', 'img/test2-neutral.PNG'].concat(stimuli);

  jsPsych.pluginAPI.preloadImages(images, function () {startExperiment();});
  console.log("Images preloaded.");


