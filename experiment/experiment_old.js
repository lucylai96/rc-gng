// Policy Complexity as Set Size in Go/NoGo Task
// Previous Work By Haley Dorfman
// Updated June 2020 by Emma Rogge for Lucy Lai's experiment
// 160 trials, 40 trials of each condition
// 2 blocks

function getStimStem(elem) {
  return String(elem.substring(0, elem.length - 4));
};

function getReward(elem) {
  return elem + '-r.PNG'
};

function getNeutral(elem) {
  return elem + '-n.PNG'
};

function getOutcome(elem) {
  var outcome = (elem.indexOf('reward') !== -1 ? 1 : 0);
  return outcome
};

/* Given the previous trial stimulus, correctness of subject response and reward context, returns either reward or neutral feedback. */
function getStochasticOutcome(stim, prev_trial_correct, reward_context) {
  var reward_prob = reward_context[0][0];
  var neutral_prob = reward_context[0][1];
  var R = Math.random();
  if (prev_trial_correct) {
    if (R < reward_prob) {
      return getReward(stim);
    } else {
      return getNeutral(stim);
    }
  } else {
    if (R < neutral_prob) {
      return getReward(stim);
    } else {
      return getNeutral(stim);
    }
  }
};

/* Save data to CSV */
function saveData(name, data) {
  console.log("Saving data now");
  fetch('http://localhost:5000/save_data', {
    method: 'POST',
    body: JSON.stringify({filename: name, filedata: data})
  }).then(function (response) {
    return response.text();
  }).then(function (text) {
    console.log("POST response: ");
    // Should be 'ok' if successful
    console.log(text);
  });
}; 

var stimuli = [
  "img/blue.PNG",
  "img/red.PNG",
  "img/green.PNG",
  "img/grey.PNG",
  "img/purple.PNG",
  "img/pink.PNG",
  "img/yellow.PNG",
  "img/orange.PNG"
];

  var timeline = [];
  var num_trials_per_stim = 10;
  var num_blocks = 2;
  
  /* Obtain consent */
  var consent_block = check_consent();
  //timeline.push(consent_block);

  /* Instructions */
  var instructions_block = create_instructions(timeline);
  timeline.push(instructions_block);

  /* Practice */
  var practice_block = create_practice();
  var finish_practice = finish_practice();
  timeline.push(practice_block);
  timeline.push(finish_practice);

  /* Shuffle Stimuli Ordering*/
  var HPC_shuffled_stimuli = jsPsych.randomization.repeat(stimuli, 1);
  var LPC_shuffled_stimuli  = jsPsych.randomization.repeat(HPC_shuffled_stimuli, 1);

  // Create reward probability functions for 4 stimuli
  //var hpc_reward_context = [[0.9,0.1],[0.75, 0.25],[0.25, 0.75],[0.1,0.9]];
  var control = [[0.2 0.8],[0.8, 0.2]];
  var hs_lc = [[0.4 0.6],[0.6, 0.4],[0.4, 0.6],[0.6, 0.4]]; // high similarity, low control
  var hs_hc = [[0.2 0.8],[0.8, 0.2],[0.2 0.8],[0.8, 0.2]];  // high similarity, high control
  var ls_lc = [[0.2 0.8],[0.8, 0.2],[0.4, 0.6],[0.6, 0.4]]; // low similarity, low control
  var ls_hc = [[0.2 0.8],[0.8, 0.2],[0, 1],[1, 0]]; // low similarity, high control
  var conditions = [control, hs_lc, hs_hc, ls_lc, ls_hc];

// TODO: do this within a loop than randomly choses blocks
  // Assign each reward probability function to a different stimulus
  var reward_prob_a = hpc_reward_context[0];
  var reward_prob_b = hpc_reward_context[1];
  var reward_prob_c = hpc_reward_context[2];
  var reward_prob_d = hpc_reward_context[3];

  // Initialize stimuli for two go and two nogo reward contexts
  var go_stimulus_a = HPC_shuffled_stimuli[0];
  var go_stimulus_b = HPC_shuffled_stimuli[1];
  var nogo_stimulus_c = HPC_shuffled_stimuli[2];
  var nogo_stimulus_d = HPC_shuffled_stimuli[3];

  // // Assign each reward probability function to a different stimulus
  var lpc_go_stimulus = LPC_shuffled_stimuli[0];
  var lpc_nogo_stimulus  = LPC_shuffled_stimuli[1];

  // Variable to keep track of most recent trial (to compare correctness)
  var trial_node_id = '';

  // Initialize stimuli for low-policy-complexity trials
  var lowPolicyComplexityStim = [];
  lowPolicyComplexityStim.push(
    [ { stimulus: lpc_go_stimulus,
      data: { test_part: 'trial', correct_response: 32, 
      use_rew: [[0.8,0.2]], which_stim: 'go' } },

      { stimulus: lpc_nogo_stimulus ,
      data: { test_part: 'trial', correct_response: null, 
      use_rew: [[0.2,0.8]], which_stim: 'nogo' } },      
    ] 
  );

  // Initialize stimuli for higher-policy-complexity trials
  var highPolicyComplexityStim = [];
  highPolicyComplexityStim.push(
    [ { stimulus: go_stimulus_a,
      data: { test_part: 'trial', correct_response: 32, 
      use_rew: reward_prob_a, which_stim: 'go_a' } },

      { stimulus: go_stimulus_b,
      data: { test_part: 'trial', correct_response: 32, 
      use_rew: reward_prob_b, which_stim: 'go_b' } },

      { stimulus: nogo_stimulus_c,
      data: { test_part: 'trial', correct_response: null, 
      use_rew: reward_prob_c, which_stim: 'nogo_c' } },

      { stimulus: nogo_stimulus_d,
      data: { test_part: 'trial', correct_response: null, 
      use_rew: reward_prob_d, which_stim: 'nogo_d'} }        
    ] 
  );

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
      var outcome = getStochasticOutcome(prev_trial_stim, prev_trial_correct, stim_reward_context);
      // Return the feedback with a border if the subject had 'Go' response/pressed space bar.
      if (feedback == 32) {
        console.log("OUTCOME: " + JSON.stringify(outcome));
        return '<img src="' + outcome + '" border="10">';
      } else {
        return '<img src="' + outcome + '">';
      }
    },
    choices: jsPsych.NO_KEYS,
    trial_duration: 1500,  // ms
    on_finish: function(data) {
      fb_node_id = jsPsych.currentTimelineNodeID();
      var feedback_data = jsPsych.data.getDataByTimelineNode(fb_node_id);
      var fb_full = feedback_data.select('stimulus').values[0];
      var feedback_num = getOutcome(fb_full);
      jsPsych.data.get().addToLast({feedback_num: feedback_num});
    }
  };

  var fixation = {
    type: 'html-keyboard-response',
    stimulus: '<div style="font-size:60px;">+</div>',
    choices: jsPsych.NO_KEYS,
    trial_duration: 1000 // ms
  };
 
  /{var lowPolicyComplexityBlock = {
    timeline: [trial, feedback, fixation],
    timeline_variables: lowPolicyComplexityStim[0],
    randomize_order: true,
    repetitions: num_trials_per_stim
  };

  var highPolicyComplexityBlock = {
    timeline: [trial, feedback, fixation],
    timeline_variables: highPolicyComplexityStim[0],
    randomize_order: true,
    repetitions: num_trials_per_stim
  };}/

  var between_block = {
    type: 'instructions',
    pages: [
      '<p class="center-content">You have completed half of the game.</p> Take a break if you would like and then press "Next" to continue.</p>'
    ],
    show_clickable_nav: true
  };
  console.log("About to shuffle blocks!");


  // conditions order

var  = [];
var shuffledArray = jsPsych.randomization.repeat(myArray, 1);

  for (i = 0; i < conditions.length; i++) {
      var random_num = Math.random(); // randomized block order

var reward_prob  = conditions[i]

var lowPolicyComplexityBlock = {
    timeline: [trial, feedback, fixation],
    timeline_variables: lowPolicyComplexityStim[0],
    randomize_order: true,
    repetitions: num_trials_per_stim
  };

  var highPolicyComplexityBlock = {
    timeline: [trial, feedback, fixation],
    timeline_variables: highPolicyComplexityStim[0],
    randomize_order: true,
    repetitions: num_trials_per_stim
  };

    if (random_num > 0.5) {
      console.log("High then low!");
      timeline.push(highPolicyComplexityBlock);
      timeline.push(between_block);
      timeline.push(lowPolicyComplexityBlock);
    } else {
      console.log("Low then high!");
      timeline.push(lowPolicyComplexityBlock);
      timeline.push(between_block);
      timeline.push(highPolicyComplexityBlock);
    };
  }




  // Calculate bonus at end
  var bonus_block = {
    type: 'instructions',
    pages: function() {
      var correct_bonus = Math.round(100 * jsPsych.data.get().filter({correct: true}).count() / (num_blocks * 2 * num_trials_per_stim + 2)); // Includes practices (+2)
      jsPsych.data.addDataToLastTrial({"bonus": correct_bonus});
      return ['<p class="center-content">You won a bonus of <b>$' + (correct_bonus == 100 ? '1.00' : '0.' + correct_bonus) + '</b>.</p>' +
        '<p class="center-content"> IMPORTANT: <b>Press "Next"</b> to continue to the survey questions.</p>'];
    },
    show_clickable_nav: true
  };
  timeline.push(bonus_block);

  // Survey
  var survey_workerid = {
    type: 'survey-text',
    questions: [{prompt: 'Please input your Mturk Worker ID so that we can pay you the appropriate bonus. Your ID will not be shared with anyone outside of our research team.', value: 'Worker ID'}]
  };

  var survey_comments = {
    type: 'survey-text',
    questions: [{prompt: 'We\'re always trying to improve. Please let us know if you have any comments.</br> Click "Submit Answer" to finish the experiment.', value: 'Comments'}],
    button_label: 'Submit Answer'
  };
  timeline.push(survey_workerid, survey_comments);

  // Add information to data
  var subject_id =  jsPsych.randomization.randomID(8); // Random subject ID
  jsPsych.data.addProperties({
    subject_id: subject_id
  });

  var turkInfo = jsPsych.turk.turkInfo();
  jsPsych.data.addProperties({
    assignmentID: turkInfo.assignmentId
  });
  jsPsych.data.addProperties({
    mturkID: turkInfo.workerId
  });
  jsPsych.data.addProperties({
    hitID: turkInfo.hitId
  });
  jsPsych.data.addProperties({
    task_version: "v1"
  });

  /* grab data before the end of the experiment */
  console.log("Subject ID: " + JSON.stringify(subject_id));
  console.log("data: $(jsPsych.data.get())");
  var save_data = {
    type: 'call-function',
    func: 
      function()
            { 
              saveData(subject_id + '_output', jsPsych.data.get().csv());
            },
    timing_post_trial: 0
  };
  timeline.push(save_data);

  function startExperiment(){
  console.log("Timeline: " + JSON.stringify(timeline));
  jsPsych.init({
      timeline: timeline,
      on_finish: function() {
        saveData();
      }
    })
  };

images = ['img/blue-r.PNG', 'img/red-r.PNG', 'img/green-r.PNG', 'img/grey-r.PNG', 'img/purple-r.PNG', 'img/pink-r.PNG', 'img/yellow-r.PNG', 'img/orange-r.PNG','img/blue-n.PNG', 'img/red-n.PNG', 'img/green-n.PNG', 'img/grey-n.PNG', 'img/purple-n.PNG', 'img/pink-n.PNG', 'img/yellow-n.PNG', 'img/orange-n.PNG','img/test1.PNG', 'img/test1-reward.PNG', 'img/test1-neutral.PNG', 'img/test2.PNG', 'img/test2-reward.PNG', 'img/test2-neutral.PNG'].concat(stimuli);
//images = ['img/square-b-reward.PNG', 'img/square-p-reward.PNG', 'img/square-o-reward.PNG', 'img/square-y-reward.PNG', 'img/square-b-neutral.PNG', 'img/square-p-neutral.PNG', 'img/square-o-neutral.PNG', 'img/square-y-neutral.PNG', 'img/test1.PNG', 'img/test1-reward.PNG', 'img/test1-neutral.PNG', 'img/test2.PNG', 'img/test2-reward.PNG', 'img/test2-neutral.PNG', 'img/square-t-neutral.PNG', 'img/square-t-reward.PNG', 'img/square-t.PNG'].concat(stimuli);

jsPsych.pluginAPI.preloadImages(images, function () {startExperiment();});
console.log("Images preloaded.");


