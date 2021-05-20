library ieee;                                           -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                        -- dolaczenie calego pakietu 'STD_LOGIC_1164'
use ieee.std_logic_unsigned.all;                        -- dolaczenie calego pakietu 'STD_LOGIC_UNSIGNED'

package transm_lib_TB is

  procedure zegar_TB(                                   -- generator sygnalu okresowego
    constant T    :    time;                            -- czas pojedynczego okresu 
    signal   C    :out std_logic;                       -- generowany sygnal wyjsciowy 
    constant N    :    boolean := false);               -- flaga negacji (TRUE) sygnalu wyjsciowego
    
  procedure reset_TB(                                   -- generator sygnalu impulsowego
    constant T    :    time;                            -- czas dlugosci impulsu 
    signal   R    :out std_logic;                       -- generowany sygnal wyjsciowy
    constant N    :    boolean := false);               -- flaga negacji (TRUE) sygnalu wyjsciowego

  procedure wektor_TB(                                   -- generator wektora danych
    constant T    :    time;                             -- okres zmian stanu danych 
    constant P, I :    integer;                          -- wartosc poczatkowa 'P' oraz przyrost 'I' wartosci wektora
    signal   W    :out std_logic_vector;                 -- generowany wektor wyjsciowy
    constant N    :boolean := false);                    -- flaga zmiany wektora wyjsciowego w polowie okresu (TRUE)

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

  procedure wektor_TB(T : time; P, I : integer; signal W : out std_logic_vector; N: boolean := false) is
    variable Z :std_logic_vector(W'range) := (others =>'0');
  begin
    Z := Z + P;
    loop
      if (N=false) then wait for T/2; end if;
      W <= Z;
      Z := Z + I;
      if N=false then wait for T/2; else wait for T; end if;
    end loop;
  end procedure;

end package body transm_lib_TB;
