Let's say you have a long-running task.
If you don't suspend it, the single-threaded Lua runtime won't be able to process new incoming requests until your long-running task is complete.


This is where cooperative/non-preemptive multitasking comes in handy.
The idea is that you choose a place in the long-running task where the Lua runtime can pause it and switch to other tasks.
Later, the runtime will automatically return to the paused task.
