library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package sim_lib is

  procedure sim_ctrl_sig(                               -- sterownik stanow sygnalu logicznego 's'
    constant L, H       :      integer;                 -- L/H liczba 'taktow' stanu niskiego/wyskokiego sygnalu 's' 
    variable c          :inout integer;                 -- licznik 'taktow'
    variable b          :inout boolean;                 -- flaga blokady zmiany stanu - stan '1'
    signal   s          :inout std_logic);              -- sygnal sterowny
                         
  procedure sim_ctrl_sig(                               -- sterownik stanow wektora logicznego 's'
    constant U, Z, I    :      integer;                 -- H/Z liczba 'taktow' stanu utrzymania/zmiany o 'I' sygnalu 's' 
    variable c          :inout integer;                 -- licznik 'taktow'
    variable b          :inout boolean;                 -- flaga blokady zmiany stanu - stan '1'
    signal   s          :inout std_logic_vector);       -- sygnal sterowny

  procedure sim_ctrl_tst(                               -- sterownik cyklu testowania
    constant Z, A       :      time;                    -- B/A czas zatrzymania/aktywacji okresu testu, B+A='takt'
    variable b          :out   boolean;                 -- flaga blokady zmiany stanu - ustawienie stanu '0'
    signal   e          :out   std_logic);              -- warunkujacy sygnal testowania

    function sin1(                                      -- odwzorowanie funcji 'sinus' dla 100 punktow
      constant a1       : real                          -- argument funcji 'sinus' w zakresie <0:1) - odpowiada <0:2pi)
    ) return real;                                      -- wartosc funcji 'sinus'

end package sim_lib;

package body sim_lib is

  procedure sim_ctrl_sig(constant L, H :integer; variable c: inout integer; variable b: inout boolean; signal s :inout std_logic) is
    variable o :std_logic;
  begin
    c := c + 1; if (c=L+H) then c := 0; end if;
    if (c<L) then o := '0'; else o := '1'; end if;  
    if (o /= s) then if (b=true) then return; else s <= o; b := true; end if; end if;
  end procedure sim_ctrl_sig;

  procedure sim_ctrl_sig(constant U, Z, I :integer; variable c: inout integer; variable b: inout boolean; signal s :inout std_logic_vector) is
    variable f :boolean;
    variable o :std_logic_vector(s'range);
  begin
    f := false; if (c<0) then c := -c; f := true; end if;
    c := c + 1; if (c=U+Z) then c := 0; end if;
    o := s; if (c=0 or c=U or f=true) then o := o + I; end if;  
    if (o /= s) then if (b=true) then c := -c; return; else s <= o; b := true; end if; end if;
  end procedure sim_ctrl_sig;

  procedure sim_ctrl_tst(constant Z, A :time; variable b: out boolean; signal e :out std_logic) is
  begin
    e <= '0';
    wait for Z;
    e <= '1';
    wait for A;
    b := false;
  end procedure sim_ctrl_tst;

 function sin1(a1: real) return real is
   constant val :real_vector := (
     0.000000,0.062791,0.125333,0.187381,0.248690,0.309017,0.368125,0.425779,0.481754,0.535827,0.587785,0.637424,0.684547,0.728969,0.770513,0.809017,0.844328,
     0.876307,0.904827,0.929776,0.951057,0.968583,0.982287,0.992115,0.998027,1.000000,0.998027,0.992115,0.982287,0.968583,0.951057,0.929776,0.904827,0.876307,
     0.844328,0.809017,0.770513,0.728969,0.684547,0.637424,0.587785,0.535827,0.481754,0.425779,0.368125,0.309017,0.248690,0.187381,0.125333,0.062791,0.000000,
     -0.062791,-0.125333,-0.187381,-0.248690,-0.309017,-0.368125,-0.425779,-0.481754,-0.535827,-0.587785,-0.637424,-0.684547,-0.728969,-0.770513,-0.809017,
     -0.844328,-0.876307,-0.904827,-0.929776,-0.951057,-0.968583,-0.982287,-0.992115,-0.998027,-1.000000,-0.998027,-0.992115,-0.982287,-0.968583,-0.951057,
     -0.929776,-0.904827,-0.876307,-0.844328,-0.809017,-0.770513,-0.728969,-0.684547,-0.637424,-0.587785,-0.535827,-0.481754,-0.425779,-0.368125,-0.309017,
     -0.248690,-0.187381,-0.125333,-0.062791);
     variable i:integer;         
 begin
   return(val(integer(a1*100.0) mod 100));
 end function;

end package body sim_lib;
