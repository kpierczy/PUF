library ieee;                                                           -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                                        -- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_unsigned.all;                                    -- dolaczenie calego pakietu 'STD_LOGIC_UNSIGNED'

entity DE_REG_SIM_TB is                                                 -- sprzeg projektu symulacji 'DE_REG_SIM_TB'
  generic(                                                              -- deklaracja parametrow
    STEP	:time    := 20ns;                                       -- ustalenie kroku czasu 'STEP'
    WIDTH       :integer := 8                                           -- ustalenie rozmiaru 'WIDTH'
  );                                                                    -- zakonczenie deklaracji parametrow
end DE_REG_SIM_TB;                                                      -- zakonczenie deklaracji sprzegu
architecture behavioural of DE_REG_SIM_TB is                            -- cialo architektoniczne projektu
  signal R, S, L, C, E :std_logic := '0';                               -- symulacja bitow wejsciowych 'R', 'S', 'L', 'C', 'E'
  signal V, D  :std_logic_vector(WIDTH-1 downto 0) := (others => '0');  -- symulacja wektorow wejsciowych 'V', 'D'
  signal Q     :std_logic_vector(WIDTH-1 downto 0);                     -- obserwacja wektora wyjsciowego 'Q'
begin						                        -- poczatek czesci wykonawczej architektury
  process is begin                                                      -- proces bezwarunkowy
    wait for STEP/4;                                                    -- odczekanie 1/4 czasu kroku 'STEP'
    loop                                                                -- petla nieskonczona
      C <= not(C); wait for 2*STEP/3;                                   -- przypisanie 'C' jej negacji i odczekanie 2/3 czasu kroku 'STEP'
    end loop;                                                           -- zakonczenie cyklu petli
  end process;                                                          -- zakonczenie procesu

  process is begin                                                      -- proces bezwarunkowy
    wait for STEP/2;                                                    -- odczekanie 1/2 czasu kroku 'STEP'
    loop                                                                -- petla nieskonczona
      V <= V + 7;                                                       -- przypisanie 'V' jej wartosci zwiekszonej o 7
      D <= D + 9;                                                       -- przypisanie 'D' jej wartosci zwiekszonej o 7
      wait for STEP;                                                    -- odczekanie kroku czasu 'STEP'
    end loop;                                                           -- zakonczenie cyklu petli
  end process;                                                          -- zakonczenie procesu

  process is begin                                                      -- proces bezwarunkowy
    wait for 3*STEP/5;                                                  -- odczekanie 3/5 czasu kroku 'STEP'
    loop                                                                -- petla nieskonczona
      E <= not(E);                                                      -- przypisanie 'E' jej negacji
      wait for 2*STEP;                                                  -- odczekanie 2 krokow czasu 'STEP'
    end loop;                                                           -- zakonczenie cyklu petli
  end process;                                                          -- zakonczenie procesu

  process is begin                                                      -- proces bezwarunkowy
    S <= '0'; wait for STEP;                                            -- ustawienie 'S' na '0' i odczekanie kroku czasu 'STEP'
    S <= '1'; wait for STEP;                                            -- ustawienie 'S' na '1' i odczekanie kroku czasu 'STEP'
    S <= '0'; wait for STEP;                                            -- ustawienie 'S' na '0' i odczekanie kroku czasu 'STEP'
    R <= '1'; wait for STEP;                                            -- ustawienie 'R' na '1' i odczekanie kroku czasu 'STEP'
    R <= '0'; wait for 10*STEP;                                         -- ustawienie 'R' na '0' i odczekanie 10-ciu krokow czasu 'STEP'
    L <= '1'; wait for 10*STEP;                                         -- ustawienie 'L' na '1' i odczekanie 10-ciu krokow czasu 'STEP'
    L <= '0'; wait for STEP;                                            -- ustawienie 'L' na '0' i odczekanie kroku czasu 'STEP'
  end process;                                                          -- zakonczenie procesu
  
  de_reg_sim_inst: entity work.DE_REG_SIM generic map(WIDTH) port map(R, S, L, V, C, E, D, Q); -- instancja projektu 'DE_REG_SIM'

end behavioural;                                                        -- zakonczenie ciala architektonicznego
