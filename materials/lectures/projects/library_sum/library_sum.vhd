library work;						-- klauzula dostepu do biblioteki 'work'
use     work.PACKAGE_SUM.all;				-- dolaczenie calego pakietu 'PACKAGE_SUM'

entity LIBRARY_SUM is					-- deklaracja sprzegu LIBRARY_SUM'
  port (  A1 : in  bit_vector(3 downto 0);		-- deklaracja portu wejsciowego 'A1'
          A2 : in  bit_vector(3 downto 0);		-- deklaracja portu wejsciowego 'A2'
	  Y  : out bit_vector(3 downto 0));	 	-- deklaracja portu wyjsciowego 'Y'
end LIBRARY_SUM;	 				-- zakonczenie deklaracji naglowka

architecture cialo of LIBRARY_SUM is		-- deklaracja ciala 'cialo' architektury

begin							-- poczatek czesci wykonawczej

  Y <= A1+sumator(A2,A2);				-- wywolanie operatora '+' oraz funcji 'sumator'

end architecture cialo;					-- zakonczenie deklaracji ciala 'cialo'
