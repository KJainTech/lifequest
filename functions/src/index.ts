import { setGlobalOptions } from 'firebase-functions/v2';

setGlobalOptions({ region: 'europe-west1', maxInstances: 10 });

export { submitQuiz } from './economy/submitQuiz';
export { submitGamePlay } from './economy/submitGamePlay';
export { completeLesson } from './economy/completeLesson';
export { runScreening } from './screening/runScreening';
export { linkChild } from './parent/linkChild';
export { createClass } from './classes/createClass';
export { joinClass } from './classes/joinClass';
export { generateCoachNote } from './coach/generateCoachNote';
export { refreshContent } from './content/refreshContent';
export { generateContent, approveContent } from './content/generateContent';
export { generateAdaptiveLesson } from './content/generateAdaptiveLesson';
