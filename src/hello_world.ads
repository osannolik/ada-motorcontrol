with System;

package Hello_World is

   task Blinker with
      Storage_Size => (4 * 1024);

   task Sampler with
      Priority => System.Priority'Last,
      Storage_Size => (4 * 1024);

end Hello_World;
