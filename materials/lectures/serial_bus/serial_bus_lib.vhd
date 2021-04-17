library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_unsigned.all;

package serial_bus_lib is

  function test_slow(t, s :std_logic_vector) return std_logic_vector; -- funkcja wyznaczajaca slowo testowe

end package serial_bus_lib;

package body serial_bus_lib is

  function test_slow(t, s :std_logic_vector) return std_logic_vector is -- funkcja wyznaczajaca slowo testowe
  begin								-- cialo funkcji wyznaczajacej slowo testowe
    return ((t + not(s)) xor s);				-- wyznaczenie i zwrocenie wartosci testowej
  end function;							-- zakonczenie funkcji wyznaczajacej slowo testowe

end package body serial_bus_lib;
