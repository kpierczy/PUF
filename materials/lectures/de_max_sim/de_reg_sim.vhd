library ieee;                                                                   -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                                                -- dolaczenie calego pakietu 'STD_LOGIC_1164'

entity DE_REG_SIM is                                                            -- deklaracja sprzegu 'DE_REG_SIM'
  generic(                                                                      -- deklaracja parametrow
    WIDTH       :integer := 8                                                   -- deklaracja parametru rozmiaru 'WIDTH'
  );                                                                            -- zakonczenie deklaracji parametrow
  port(                                                                         -- deklaracja portow
    R           :in  std_logic := '0';                                          -- deklaracja kasujacego portu wejsciowego 'R'
    S           :in  std_logic := '0';                                          -- deklaracja ustawiajacego portu wejsciowego 'S'
    L           :in  std_logic := '0';                                          -- deklaracja portu wejsciowego zapisu asynchr. 'L'
    V           :in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');     -- deklaracja portu wejsc. asynch. wektora danych 'V'
    C           :in  std_logic := '0';                                          -- deklaracja portu wejsciowego zegara 'C'
    E           :in  std_logic := '1';                                          -- deklaracja portu wejsciowego apisu synch. 'E'
    D           :in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');     -- deklaracja portu wejsc. synch. wektora danych 'D'
    Q           :out std_logic_vector(WIDTH-1 downto 0)                         -- deklaracja portu wyjsciowego danych 'Q'
  );                                                                            -- zakonczenie deklaracja portow
end DE_REG_SIM;                                                                 -- zakonczenie deklaracji sprzegu

architecture cialo of DE_REG_SIM is			                        -- deklaracja architektury 'cialo'
begin						                                -- poczatek czesci wykonawczej architektury
  process(R, S, L, V, C) is begin                                               -- lista czulosci procesu
    if (R='1') then                                                             -- badanie, czy sygnal 'R' ma wartosc '1'
      Q <= (others => '0');                                                     -- jeœli tak, asynch. ustaw. bitow 'Q' na wartosc '0'
    elsif (S='1') then                                                          -- badanie, czy sygnal 'S' ma wartosc '1'
      Q <= (others => '1');                                                     -- jeœli tak, asynch. ustaw. bitow 'Q' na wartosc '1'
    elsif (L='1') then                                                          -- badanie, czy sygnal 'L' ma wartosc '1'
      Q <= V;                                                                   -- jeœli tak, asynch. przypisanie do 'Q' sygnalu 'V'
    elsif (C'event) then                                                        -- badanie, czy wystapilo zbocze na sygnale 'C'
      if (E='1') then                                                           -- badanie, czy sygnal 'E' ma wartosc '1'
        Q <= D;                                                                 -- jeœli oba tak, synch. przypisanie do 'Q' sygnalu 'D'
      end if;                                                                   -- zakonczenie warunku zapisu synchronicznego
    end if;                                                                     -- zakonczenie wielokrotnych warunkow 
  end process;                                  	                        -- zakonczenie procesu
end architecture cialo;                                                         -- zakonczenie architektury 'cialo'
		