library ieee;
use     ieee.std_logic_1164.all;

entity ASSERT_DEMULTIPL1 is					-- deklaracja sprzegu ASSERT_DEMULTIPL'
  generic (
    X_SZEROKOSC		:natural := 4;				-- szerokosci slowa 'X'
    Y_SZEROKOSC		:natural := 12				-- szerokosci slowa 'Y'
  );
  port (  X : in  std_logic_vector (X_SZEROKOSC-1 downto 0);	-- deklaracja portu wejsciowego 'X'
          I : in  natural;					-- deklaracja portu wejsciowego 'I'
          Y : out std_logic_vector (Y_SZEROKOSC-1 downto 0)	-- deklaracja portu wyjsciowego 'Y'
       ); 							-- zakonczenie deklaracji listy portow
end ASSERT_DEMULTIPL1;	 					-- zakonczenie deklaracji naglowka

architecture cialo of ASSERT_DEMULTIPL1 is			-- deklaracja ciala 'cialo' architektury

begin								-- poczatek czesci wykonawczej

  process (X, I) is						-- proces asynchroniczny
  begin								-- pocz¹tek ciala procesu 

    assert (I+1)*X'length-1<=Y'left				-- badanie poprawnosci reguly
      report "przekroczono zakres indeksowania"			-- informacja gdy regula nie jest spelniona
      severity error;						-- obsluga niezgodnosci na poziomie bledu
    
    Y <= (others =>'0');					-- wyzerowanie wektora wyjsciowek
    Y((I+1)*X'length-1 downto X'length*I) <= X;			-- wprowadzenie 'X' do 'Y' gd indeksu 'I'

  end process;							-- zakonczenie ciala procesu

end architecture cialo;						-- zakonczenie deklaracji ciala 'cialo'
