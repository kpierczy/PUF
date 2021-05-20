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

end package body sim_lib;
