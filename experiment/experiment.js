// Policy Complexity as Set Size in Go/NoGo Task
// Previous Work By Hayley Dorfman
// Updated June 2020 by Emma Rogge for Lucy Lai's experiment


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

/* Save data to CSV */
// function saveData(name, data) {
//   console.log("Saving data now");
//   fetch('http://localhost:5000/save_data', {
//     method: 'POST',
//     body: JSON.stringify({filename: name, filedata: data})
//   }).then(function (response) {
//     return response.text();
//   }).then(function (text) {
//     console.log("POST response: ");
//     // Should be 'ok' if successful
//     console.log(text);
//   });
// }; 

function saveData(name, data) {
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'write_data.php'); // 'write_data.php' is the path to the php file described above.
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send(JSON.stringify({
      filename: name,
      filedata: data
    }));
  }


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
var num_trials_per_stim = 1;
var num_blocks = 5;

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

  // Create reward probability functions for 4 stimuli
  //var hpc_reward_context = [[0.9,0.1],[0.75, 0.25],[0.25, 0.75],[0.1,0.9]];
  var control = [[0.8, 0.2],[0.2, 0.8]]; // control (go, no-go)
  var hs_lc = [[0.6, 0.4],[0.4, 0.6],[0.6, 0.4],[0.4, 0.6]]; // high similarity, low control
  var hs_hc = [[0.8, 0.2],[0.2, 0.8],[0.8, 0.2],[0.2, 0.8]];  // high similarity, high control
  var ls_lc = [[0.8, 0.2],[0.2, 0.8],[0.6, 0.4],[0.4, 0.6]]; // low similarity, low control
  var ls_hc = [[0.8, 0.2],[0.2, 0.8],[1, 0], [0, 1]]; // low similarity, high control
  var conditions = [control, hs_lc, hs_hc, ls_lc, ls_hc];
  console.log(control);
  console.log(conditions);

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
    use_rew: reward_prob_a, which_stim: 'go_a'} },
    { stimulus: nogo_stimulus_b,
      data: { test_part: 'trial', correct_response: null, 
      use_rew: reward_prob_b, which_stim: 'nogo_b'} }
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
var order = [2,3,4,5]
var order = jsPsych.randomization.repeat(order, 1);

for (i = 1; i < conditions.length; i++) {
      var block = order[i]; // randomized block order
      var reward_prob  = conditions[i]
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
          use_rew: reward_prob_a, which_stim: 'go_a' } },

          { stimulus: nogo_stimulus_b,
            data: { test_part: 'trial', correct_response: null, 
            use_rew: reward_prob_b, which_stim: 'nogo_b' } },

            { stimulus: go_stimulus_c,
              data: { test_part: 'trial', correct_response: 32, 
              use_rew: reward_prob_c, which_stim: 'go_c' } },

              { stimulus: nogo_stimulus_d,
                data: { test_part: 'trial', correct_response: null, 
                use_rew: reward_prob_d, which_stim: 'nogo_d'} }        
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
  var subject_id =  jsPsych.randomization.randomID(5); // Random subject ID
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

  images = ['img/blue-r.png', 'img/red-r.png', 'img/green-r.png', 'img/grey-r.png', 'img/purple-r.png', 'img/pink-r.png', 'img/yellow-r.png', 'img/orange-r.png','img/blue-n.png', 'img/red-n.png', 'img/green-n.png', 'img/grey-n.png', 'img/purple-n.png', 'img/pink-n.png', 'img/yellow-n.png', 'img/orange-n.png','img/test1.PNG', 'img/test1-reward.PNG', 'img/test1-neutral.PNG', 'img/test2.PNG', 'img/test2-reward.PNG', 'img/test2-neutral.PNG'].concat(stimuli);

jsPsych.pluginAPI.preloadImages(images, function () {startExperiment();});
console.log("Images preloaded.");


