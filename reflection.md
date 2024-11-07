In addition to the code, data, and graphs you should complete a short
written reflection on this process.
Answer the following questions:

- Did your graph match your runtime analysis expectations?

 - It did not. I think there are 2 big reasons for this:
  1. I have all of, like, 0 handle on how to use cudaMemCpy or what CUDA memory is accessible from where. I'm still using cudaMallocManaged. Apologies. Meeting w you tmrw to try to figure it out better
  2. I didn't scale high enough for the cpu version to take much longer than the mkernels one, and my math was bad in a way that made mkernels take more than a proper O(sqrt(n)), which is its math-optimized form.
 - So the naive approach, especially with mallocManaged, should have taken much longer and been much more unreliable, but the cpu approach should have been slower than mkernels, not faster

- What went well with this assignment?
 - i liked implementing multiple kernel approach. i liked the approach. it was fun. i would bet like 96% of the class implemented recursive doubling instead. here i am being probably the only person not to :) it was fun 10/10 would do again
 - kernel logic was good
- What was difficult?
 - teaching myself seaborn, data wrangling, and python all at once lol
 - pandas data wrangling
 - math
 - maintaining my data to export immediately to a csv so i could collect it en masse without too much effort
 - mkernels really didn't like what should have been aceptably adding into sums inside of the first kernel, which i believe would have made a minor optimization
 - manual memory copying to cuda for optimized performance
- How would you approach differently?
 - write a separate script to initalize the csv files every time. I created it inside the file on the first run rather than before running, but it would have saved time and duplication of effort to initialize the csvs first and then run each file with ascending sizes and appending the results to the csv every time.
 - fix the memory stuff so i'm using optimized memory and not mallocManaged
 - get data for higher numbers to make the graph actually look right
- Anything else you want me to know?
 - nope