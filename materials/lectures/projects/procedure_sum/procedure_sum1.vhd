entity PROCEDURE_SUM1 is				-- deklaracja sprzegu PROCEDURE_SUM1'
  port (  A1 : in  bit_vector(3 downto 0);		-- deklaracja portu wejsciowego 'A1'
          A2 : in  bit_vector(3 downto 0);		-- deklaracja portu wejsciowego 'A2'
	  YA : out bit_vector(3 downto 0);	 	-- deklaracja portu wyjsciowego 'YA'
	  CA : out bit;				 	-- deklaracja portu wyjsciowego 'CA'
	  YB : out bit_vector(2 downto 0);	 	-- deklaracja portu wyjsciowego 'YB'
	  CB : out bit				 	-- deklaracja portu wyjsciowego 'CB'
       ); 						-- zakonczenie deklaracji listy portow
end PROCEDURE_SUM1;	 				-- zakonczenie deklaracji naglowka

architecture cialo of PROCEDURE_SUM1 is			-- deklaracja ciala 'cialo' architektury

  procedure sum3b(A, B :bit; S :out bit ; P :inout bit) is -- utworzenie procedury 'sum3b'
  begin							-- czesc wykonawcza procedury
    if (P='0') then					-- badanie czy bit przeniesienia jest rowny '0'
      S := A xor B;					-- sumowanie bitowe funkcja 'xor'
      P := A and B;					-- wyznaczenie bitu przeniesienia funkcja 'and'
    else						-- wariant dla 'P' rownego '1'
      S := A xnor B;					-- sumowanie bitowe funkcja 'xnor'
      P := A or   B;					-- wyznaczenie bitu przeniesienia funkcja 'or'
    end if;						-- zakonczenie instukcji warunkowej
  end procedure sum3b;					-- zakonczenie procedury
  
  procedure sumator(					-- deklaracja procedury 'sumator'
    signal A, B : in  bit_vector;			-- wejsciowe sygnaly typu  'bit_vector'
    signal Y    : out bit_vector;			-- wyjsciowy sygnal typu 'bit_vector'
    signal C    : out bit)				-- wyjsciowy sygnal typu 'bit'
  is							-- czesc deklaracyjna procedury
    variable P, S : bit;				-- utworzenie zmiennych 'P' i 'S' w procedurze
  begin							-- czesc wykonawcza procedury
    P := '0';						-- ustawienie wartosci poczatkowej 'P' na '0'
    for i in 0 to Y'length-1 loop			-- petla po kolejnych bitach dla identyfikatora 'i'
      sum3b(A(i),B(i),S,P);				-- wywolanie procedury 'sum3b'
      Y(i) <= S;					-- przypisanie zmiennej 'S' do sygnalu 'Y(i)'
    end loop;						-- zakonczenie petli
    C <= P;						-- przypisanie zmiennej'P' do sygnalu 'C'
  end procedure sumator;				-- zakonczenie procedury

begin							-- poczatek czesci wykonawczej

  sumator(A1, A2, YA, CA);				-- wywolanie procedury 'sumator' z przypisaniami przez pozycje
  sumator(C=>CB, A=>A1(2 downto 0), Y=>YB, B=>A2(2 downto 0)); -- wywolanie procedury 'sumator' z przypisaniami przez nazwe

end architecture cialo;					-- zakonczenie deklaracji ciala 'cialo'
