library ieee;                                   -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                -- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     work.transm_lib_TB.all;                 -- dolaczenie calego pakietu uzykownika 'TRANS_LIB_TB'

entity TRANSM_STROBE_TB is			-- pusty sprzeg projektu symulacji 'TRANSM_STROBE_TB'
end TRANSM_STROBE_TB;                           -- zakonczenie deklaracji sprzegu

architecture cialo_tb of TRANSM_STROBE_TB is	-- cialo architektoniczne projektu 'cialo_tb'

  constant C_MULT       :positive := 8;         -- zwielokrotnienie zegara 'MC'
  signal   R            :std_logic;	        -- symulowane wejscie 'R'
  signal   C            :std_logic;             -- symulowane wejscie 'C'
  signal   MC           :std_logic;             -- symulowane wejscie 'MC'
  signal   STR          :std_logic;             -- obserwowane wyjscie 'STR'

begin						-- poczatek czesci wykonawczej architektury

  reset_TB(10 ns,         R);                   -- sterowanie sygnalem 'R' przez funkcje 'reset_TB'
  zegar_TB(C_MULT*10 ns,  C);                   -- sterowanie sygnalem 'C' przez funkcje 'zegar_TB'
  zegar_TB(10 ns,         MC);                  -- sterowanie sygnalem 'MC' przez funkcje 'zegar_TB'

  test_inst: entity work.TRANSM_STROBE          -- instancja testowanego projektu 'TRANSM_STROBE'
    generic map(			        -- mapowanie parametrow
      C_MULT    => C_MULT)                      -- mapowanie parametru 'C_MULT' 
    port map (                                  -- mapowanie portow
      R         => R,                           -- przypisanie sygnalu 'R' do portu 'R'
      C         => C,                           -- przypisanie sygnalu 'C' do portu 'C'
      MC        => MC,                          -- przypisanie sygnalu 'MC' do portu 'MC'
      STR       => STR                          -- przypisanie sygnalu 'STR' do portu 'STR'
    );                                          -- zakonczenie mapowania portow
end architecture cialo_tb;                      -- zakonczenie ciala architektonicznego 'cialo_tb'
