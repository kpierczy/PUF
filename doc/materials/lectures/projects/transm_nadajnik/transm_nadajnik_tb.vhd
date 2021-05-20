library ieee;                                           -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                        -- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_unsigned.all;                    -- dolaczenie calego pakietu 'STD_LOGIC_UNSIGNED'
use     work.transm_lib_TB.all;                         -- dolaczenie calego pakietu uzykownika 'TRANS_LIB_TB'

entity TRANSM_NADAJNIK_TB is			        -- pusty sprzeg projektu symulacji 'TRANSM_NADAJNIK_TB'
end TRANSM_NADAJNIK_TB;                                 -- zakonczenie deklaracji sprzegu

architecture cialo_tb of TRANSM_NADAJNIK_TB is	        -- cialo architektoniczne projektu 'cialo_tb'

  constant C_MULT       :positive := 8;                 -- zwielokrotnienie zegara 'MC'
  signal   R            :std_logic;	                -- symulowane wejscie 'C'
  signal   C            :std_logic;	                -- symulowane wejscie 'C'
  signal   MC           :std_logic;	                -- symulowane wejscie 'MC'
  signal   D            :std_logic_vector(C_MULT-1 downto 0) := (others =>'0'); -- symulowane wejscie 'D'
  signal   T            :std_logic;	                -- symulowane wejscie 'T'
  signal   TX           :std_logic;	                -- symulowane wejscie 'TX'

begin

  reset_TB (100 ns,              R);                    -- sterowanie sygnalem 'R' przez funkcje 'reset_TB'
  zegar_TB (C_MULT*10 ns,        C);                    -- sterowanie sygnalem 'C' przez funkcje 'zegar_TB'
  zegar_TB (10 ns,               MC);                   -- sterowanie sygnalem 'MC' przez funkcje 'zegar_TB'
  wektor_TB(C_MULT*10 ns, 0, 13, D);                    -- sterowanie sygnalem 'OB' przez funkcje 'dana_TB'
  zegar_TB (20*C_MULT*10 ns,     T);                    -- sterowanie sygnalem 'T' przez funkcje 'zegar_TB'

  nad_inst: entity work.TRANSM_NADAJNIK                 -- instancja testowanego projektu 'NADAJNIK'
    generic map(                                        -- mapowanie parametrow
      C_MULT    => C_MULT)                              -- mapowanie parametru 'C_MULT' 
    port map (                                          -- mapowanie portow
      R         => R,                                   -- przypisanie sygnalu 'R' do portu 'R'
      C         => C,                                   -- przypisanie sygnalu 'C' do portu 'C'
      MC        => MC,                                  -- przypisanie sygnalu 'MC' do portu 'MC'
      D         => D,                                   -- przypisanie sygnalu 'D' do portu 'D'
      T         => T,                                   -- przypisanie sygnalu 'T' do portu 'T'
      TX        => TX                                   -- przypisanie sygnalu 'TX' do portu 'TX'
    );

end cialo_tb;			                        -- zakonczenie ciala architektonicznego 'cialo_tb'
