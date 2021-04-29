function getPolicyComplexityBlock(stimuli, num_trials_per_stim) {
  var cue_stimuli = [];
    cue_stimuli.push(stimuli);

  var fixation = {
      type: 'html-keyboard-response',
      stimulus: '<div style="font-size:60px;">+</div>',
      choices: jsPsych.NO_KEYS,
      trial_duration: 1500 // ms
  };

  var trial = {
    type: 'image-keyboard-response',
    stimulus: jsPsych.timelineVariable('stimulus'),
    choices: [32],
    trial_duration: 2000,  // ms
    data: jsPsych.timelineVariable('data'),
    on_finish: function(data) {
      data.correct = data.key_press == data.correct_response;
      trial_node_id = jsPsych.currentTimelineNodeID();
    }
  };

  var feedback = {
    type: 'image-keyboard-response',
    data: jsPsych.timelineVariable('data'),
    stimulus: function() {
      var prev_trial = jsPsych.data.getDataByTimelineNode(trial_node_id);
      var prev_trial_correct = prev_trial.select('correct').values[0];
      var prev_trial_stim = getStimStem(prev_trial.select('stimulus').values[0]);
      // Select the reward probability function for given stimulus.
      var stim_reward_context = prev_trial.select('use_rew').values;
      return getStochasticOutcome(prev_trial_stim, prev_trial_correct, stim_reward_context);
    };
    choices: jsPsych.NO_KEYS,
      trial_duration: 1500,  // ms
      on_finish: function(data) {
        fb_node_id = jsPsych.currentTimelineNodeID();
        var feedback_data = jsPsych.data.getDataByTimelineNode(fb_node_id);
        var fb_full = feedback_data.select('stimulus').values[0];
        var feedback_num = getOutcome(fb_full);
        jsPsych.data.get().addToLast({feedback_num: feedback_num});
      }
    }

     var block = {
      timeline: [trial, feedback, fixation],
      timeline_variables: cue_stimuli[0],
      randomize_order: true,
      repetitions: num_trials_per_stim
  };
  return block;
};