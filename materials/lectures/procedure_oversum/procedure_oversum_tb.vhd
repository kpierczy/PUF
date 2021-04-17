entity PROCEDURE_OVERSUM_TB is				-- pusty sprzeg projektu symulacji
end PROCEDURE_OVERSUM_TB;

architecture behavioural of PROCEDURE_OVERSUM_TB is	-- cialo architektoniczne projektu

  signal A1 : bit_vector(3 downto 0);			-- deklaracja portu wejsciowego 'A1'
  signal A2 : bit_vector(3 downto 0);			-- deklaracja portu wejsciowego 'A2'
  signal A3 : bit_vector(3 downto 0);			-- deklaracja portu wejsciowego 'A2'
  signal YA : bit_vector(3 downto 0);			-- deklaracja portu wyjsciowego 'YA'
  signal CA : bit;					-- deklaracja portu wyjsciowego 'CA'
  signal YB : bit_vector(4 downto 0);			-- deklaracja portu wyjsciowego 'YB'
  signal CB : bit;					-- deklaracja portu wyjsciowego 'CB'

begin							-- czesc wykonawcza ciala projektu

  process is						-- proces bezwarunkowy
  begin							-- czesc wykonawcza procesu
    A1 <= "0000"; A2 <= "0000"; A3 <= "0000"; wait for 10ns; -- ustawienie sygnalow 'A1', 'A2' i odczekanie 10 ns	
    A1 <= "0001"; A2 <= "0011"; A3 <= "0110"; wait for 10ns; -- ustawienie sygnalow 'A1', 'A2' i odczekanie 10 ns
    A1 <= "0010"; A2 <= "0111"; A3 <= "1100"; wait for 10ns; -- ustawienie sygnalow 'A1', 'A2' i odczekanie 10 ns
    A1 <= "0110"; A2 <= "0100"; A3 <= "0001"; wait for 10ns; -- ustawienie sygnalow 'A1', 'A2' i odczekanie 10 ns
    A1 <= "1000"; A2 <= "0110"; A3 <= "0111"; wait for 10ns; -- ustawienie sygnalow 'A1', 'A2' i odczekanie 10 ns
    A1 <= "1010"; A2 <= "0110"; A3 <= "1101"; wait for 10ns; -- ustawienie sygnalow 'A1', 'A2' i odczekanie 10 ns
    A1 <= "1111"; A2 <= "1111"; A3 <= "1111"; wait for 10ns; -- ustawienie sygnalow 'A1', 'A2' i odczekanie 10 ns
  end process;						-- zakonczenie procesu

  procedure_oversum_inst: entity work.PROCEDURE_OVERSUM(cialo) -- instancja projektu 'PROCEDURE_OVERSUM'
    port map (A1, A2, A3, YA, CA, YB, CB);		-- przypisanie portom sygnalow

end behavioural;					-- zakonczenie ciala architektonicznego
