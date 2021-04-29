library ieee;                                           -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                        -- dolaczenie calego pakietu 'STD_LOGIC_1164'
use ieee.std_logic_unsigned.all;                        -- dolaczenie calego pakietu 'STD_LOGIC_UNSIGNED'

package transm_lib is

  function RndGet(                                      -- generator wartosci pseudolosowej
    v      :std_logic_vector)                           -- wartosc bazowa generacji nowej warosci
    return  std_logic_vector;                           -- zwraca nowa wartosc pseudolosowa

end package transm_lib;

package body transm_lib is

  function RndGet(v: std_logic_vector) return std_logic_vector is
    constant LEN : positive := v'length;
    variable res : std_logic_vector(LEN-1 downto 0);
  begin
    res := v;
    res(4) := not(res(3) xor res(1));
    res := not(res(LEN-2 downto 0) & res(LEN-1));
    return(res);
  end function;

end package body transm_lib;

------------------------------------------------------------------------------

library ieee;                                           -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                        -- dolaczenie calego pakietu 'STD_LOGIC_1164'

entity TRANSM_STROBE is                                 -- deklaracja sprzegu 'TRANSM_STROBE'
  generic(                                              -- deklaracja parametrow
    C_MULT       :integer := 4                          -- deklaracja parametru zwielokrotnienia 'C_MULT'
  );                                                    -- zakonczenie deklaracji parametrow
  port(                                                 -- deklaracja portow
    R           :in  std_logic;                         -- deklaracja kasujacego portu wejsciowego 'R'
    C           :in  std_logic;                         -- deklaracja portu wejsciowego zegara 'C'
    MC          :in  std_logic;                         -- deklaracja portu wejsciowego zegara zwielokrotnionego 'MC'
    STR         :out std_logic                          -- deklaracja portu wyjsciowego sygnalu strobu 'STR'
  );                                                    -- zakonczenie deklaracja portow
end entity TRANSM_STROBE;                               -- zakonczenie deklaracji sprzegu

architecture cialo of TRANSM_STROBE is			-- deklaracja architektury 'cialo' dla sprzegu 'TRANSM_STROBE'
  signal R1, R2 :std_logic;				-- deklaracja rejestrow 'R1' i 'R2'
  signal P      :std_logic_vector(0 to C_MULT-2);	-- deklaracja bufora 'P'
begin						        -- poczatek czesci wykonawczej architektury

  process (R, MC) is begin                              -- lista czulosci procesu
    if (R='1') then                                     -- badanie, czy sygnal 'R' ma wartosc '1'
      R1 <= '0';                                        -- jeœli tak, asynch. ustaw. bitu 'R1' na wartosc '0'
      R2 <= '0';                                        -- jeœli tak, asynch. ustaw. bitu 'R2' na wartosc '0'
    elsif (MC'event and MC='0') then                    -- alternatywne badanie, czy wystapilo zbocze opadajace 'MC'
      R1 <= C;                                          -- jeœli tak, synch. przypisanie 'C' do bitu 'R1'
      R2 <= not(R1) and C;                              -- jeœli tak, synch. przypisanie wyrazenia do bitu 'R2'
    end if;                                             -- zakonczenie wielokrotnych warunkow 
  end process;                                          -- zakonczenie procesu

  process (R, MC) is begin                              -- lista czulosci procesu
    if (R='1') then                                     -- badanie, czy sygnal 'R' ma wartosc '1'
      P <= (others => '0');                             -- jeœli tak, asynch. ustaw. bitow wektora 'P' na wartosc '0'
    elsif (MC'event and MC='1') then                    -- alternatywne badanie, czy wystapilo zbocze narastajace 'MC'
      P(0) <= R2;                                       -- jeœli tak, synch. przypisanie 'R2' do bitu 'P(0)'
      P(1 to C_MULT-2) <= P(0 to C_MULT-3);             -- jeœli tak, synch. przesuniêcie w lewo bitow wektora 'P'
    end if;                                             -- zakonczenie wielokrotnych warunkow 
  end process;                                          -- zakonczenie procesu
  
  STR <= P(C_MULT-2);                                   -- asynchroniczne przypisanie wyrazenia do portu wyjsciowego 'STR'

end architecture cialo;                                 -- zakonczenie architektury 'cialo'