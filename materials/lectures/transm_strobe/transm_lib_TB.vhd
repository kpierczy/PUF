library ieee;                                           -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                        -- dolaczenie calego pakietu 'STD_LOGIC_1164'
use ieee.std_logic_unsigned.all;                        -- dolaczenie calego pakietu 'STD_LOGIC_UNSIGNED'

package transm_lib_TB is

  procedure zegar_TB(                                   -- generator sygnalu okresowego
    constant T :    time;                               -- czas pojedynczego okresu 
    signal   C :out std_logic;                          -- generowany sygnal wyjsciowy 
    constant N :    boolean := false);                  -- flaga negacji (TRUE) sygnalu wyjsciowego
    
  procedure reset_TB(                                   -- generator sygnalu impulsowego
    constant T :    time;                               -- czas dlugosci impulsu 
    signal   R :out std_logic;                          -- generowany sygnal wyjsciowy
    constant N :    boolean := false);                  -- flaga negacji (TRUE) sygnalu wyjsciowego

end package transm_lib_TB;

package body transm_lib_TB is

  procedure zegar_TB(T : time; signal C : out std_logic; N: boolean := false) is
  begin
    loop
      if (N=false) then C <= '1'; else C <= '0'; end if;
      wait for T/2;
      if (N=false) then C <= '0'; else C <= '1'; end if;
      wait for T/2;
    end loop;
  end procedure;

  procedure reset_TB(T : time; signal R : out std_logic; N: boolean := false) is
  begin
    if (N=false) then R <= '1'; else R <= '0'; end if;
    wait for T;
    if (N=false) then R <= '0'; else R <= '1'; end if;
    wait;
  end procedure;

end package body transm_lib_TB;
