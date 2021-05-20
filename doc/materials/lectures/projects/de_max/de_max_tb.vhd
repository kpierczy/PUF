library ieee;                                                           -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                                        -- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_unsigned.all;                                    -- dolaczenie calego pakietu 'STD_LOGIC_UNSIGNED'
use     ieee.std_logic_misc.all;                                        -- dolaczenie calego pakietu 'STD_LOGIC_MISC'
use     work.sim_lib.all;                                               -- dolaczenie calego pakietu wlasnego 'SIM_LIB'

entity DE_MAX_TB is                                                     -- sprzeg projektu symulacji 'DE_MAX_SIM_TB'
  generic(                                                              -- deklaracja parametrow
    PROBE_ns		:real    := 40.0;                               -- ustalenie czasu probkowania 'PROBE_ns' w [ns]                                
    TSIN1_ns		:real    := 10000.0*PROBE_ns;                   -- ustalenie okresu 'TSIN1_ns' okresu sinusoidy 1 w [ns] 
    TSIN2_ns	        :real    := 300.0*PROBE_ns;                     -- ustalenie okresu 'TSIN2_ns' okresu sinusoidy 2 w [ns] 
    WIDTH		:natural := 8                                   -- ustalenie rozmiaru danych 'WIDTH'
  );                                                                    -- zakonczenie deklaracji parametrow
end DE_MAX_TB;                                                          -- zakonczenie deklaracji sprzegu

architecture cialo of DE_MAX_TB is                                      -- deklaracja architektury 'cialo' dla sprzegu 'DE_MAX_TB'
  signal R, S, L, C, E :std_logic := '0';                               -- symulacja bitow wejsciowych 'R', 'S', 'L', 'C', 'E'
  signal V, D          :std_logic_vector(WIDTH-1 downto 0) := (others => '0');  -- symulacja wektorow wejsciowych 'V', 'D'
  signal hM, sM        :std_logic_vector(WIDTH-1 downto 0) := (others =>'0');   -- obserwacja wektorow wyjsciowych 'hM', 'sM'
  signal eM            :std_logic := '0';                               -- obserwacja bledu 'eE'
begin

  process is begin                                                      -- proces bezwarunkowy
    C <= '1'; wait for PROBE_ns*1ns;                                    -- ustawienie 'C' na '1' i odczekanie czasu 'PROBE_ns' w [ns]
    C <= '0'; wait for PROBE_ns*1ns;                                    -- ustawienie 'C' na '0' i odczekanie czasu 'PROBE_ns' w [ns]
  end process;                                                          -- zakonczenie procesu

  process is                                                            -- proces bezwarunkowy
    variable a1, a2 :real;                                              -- zmienne dla wartosci dwoch funkcji sinus
    constant Z :std_logic_vector(WIDTH-1 downto 0) := (others => '0');  -- stala dla wartosc 0 wektora
  begin                                                                 -- czesc wykonawcza procesu
    R <= '0'; S <= '0'; L <= '0';  E <= '1';                            -- przypisanie wartosci sygnalow 'R', 'S', 'L' na '0' i 'E' na '1'
    V <= (others => '0'); D <= (others => '0');                         -- przypisanie wartosci sygnalow wektorowych 'V' i 'D' na 0
                         wait for PROBE_ns/2*1ns;                       -- odczekanie 1/2 okresu 'PROBE_ns' w [ns]
    D <= D+13; R <= '1'; wait for PROBE_ns*1ns;                         -- zwiekszenie D o 13, ustawienie 'R' na '1' i odczekanie okresu 'PROBE_ns' w [ns]
    R <= '0';            wait for PROBE_ns*1ns;                         -- ustawienie 'R' na '0' i odczekanie okresu 'PROBE_ns' w [ns]
    S <= '1';            wait for PROBE_ns*1ns;                         -- ustawienie 'S' na '1' i odczekanie okresu 'PROBE_ns' w [ns]
    S <= '0';            wait for PROBE_ns*1ns;                         -- ustawienie 'S' na '0' i odczekanie okresu 'PROBE_ns' w [ns]
    L <= '1';            wait for PROBE_ns*1ns;                         -- ustawienie 'L' na '1' i odczekanie okresu 'PROBE_ns' w [ns]
    V <= V+13;           wait for PROBE_ns*1ns;                         -- zwiekszenie V o 13 i odczekanie okresu 'PROBE_ns' w [ns]
    V <= V+13;           wait for PROBE_ns*1ns;                         -- zwiekszenie V o 13 i odczekanie okresu 'PROBE_ns' w [ns]
    L <= '0';            wait for PROBE_ns*1ns;                         -- ustawienie 'L' na '0' i odczekanie okresu 'PROBE_ns' w [ns]
    V <= V+13;           wait for PROBE_ns*1ns;                         -- zwiekszenie V o 13 i odczekanie okresu 'PROBE_ns' w [ns]
    for t in 1 to 2000 loop                                             -- wykonanie 2000 cykli petli indeksowanej przez 't'
      a1 := sin1((real(t)*PROBE_ns)/TSIN1_ns);                          -- przypisanie 'a1' wartosci 'sinus' o okresie 'TSIN1_ns' dla czasu 't*PROBE_ns'
      a2 := sin1((real(t)*PROBE_ns)/TSIN2_ns);                          -- przypisanie 'a2' wartosci 'sinus' o okresie 'TSIN2_ns' dla czasu 't*PROBE_ns'
      D  <= Z+integer(100.0*(a1*a2+1.1));                               -- przypisanie 'D' wartosci modulacja sygnalami sinusoidalnymi 
      wait for PROBE_ns*1ns;                                            -- odczekanie okresu 'PROBE_ns' w [ns]
    end loop;                                                           -- zakonczenie cyklu petli
    L <= '1';            wait for PROBE_ns*1ns;                         -- ustawienie 'L' na '1' i odczekanie okresu 'PROBE_ns' w [ns]
    L <= '0';            wait for PROBE_ns*1ns;                         -- ustawienie 'L' na '0' i odczekanie okresu 'PROBE_ns' w [ns]
    wait;                                                               -- zatrzymanie wykonywania procesu do konca ymulacji
  end process;                                                          -- zakonczenie procesu

  de_max8_impl:    entity work.DE_MAX8                        port map(R, S, L, V, C, E, D, hM); -- instacja projektu 'DE_MAX8'
  de_max_sim_impl: entity work.DE_MAX_SIM generic map (WIDTH) port map(R, S, L, V, C, E, D, sM); -- instacja projektu 'DE_MAX_SIM'

  eM <= transport OR_REDUCE(hM xor sM) after 1ps;                       -- testowanie zgodnosci stanow sygnalow 'hM' i 'sM'

end architecture cialo;                                                 -- zakonczenie architektury 'cialo'
