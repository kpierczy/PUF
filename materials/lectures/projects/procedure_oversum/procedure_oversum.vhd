entity PROCEDURE_OVERSUM is				-- deklaracja sprzegu PROCEDURE_OVERSUM'
  port (  A1 : in  bit_vector(3 downto 0);		-- deklaracja portu wejsciowego 'A1'
          A2 : in  bit_vector(3 downto 0);		-- deklaracja portu wejsciowego 'A2'
          A3 : in  bit_vector(3 downto 0);		-- deklaracja portu wejsciowego 'A2'
	  YA : out bit_vector(3 downto 0);	 	-- deklaracja portu wyjsciowego 'YA'
	  CA : out bit;				 	-- deklaracja portu wyjsciowego 'CA'
	  YB : out bit_vector(4 downto 0);	 	-- deklaracja portu wyjsciowego 'YB'
	  CB : out bit				 	-- deklaracja portu wyjsciowego 'CB'
       ); 						-- zakonczenie deklaracji listy portow
end PROCEDURE_OVERSUM;	 				-- zakonczenie deklaracji naglowka

architecture cialo of PROCEDURE_OVERSUM is		-- deklaracja ciala 'cialo' architektury
  procedure sum(					-- deklaracja przeciazonej procedury 'sum'
    constant A, B : in  bit_vector;			-- wejsciowe sygnaly typu  'bit_vector'
    variable Y    : out bit_vector;			-- wyjsciowy sygnal typu 'bit_vector'
    variable C    : out bit)				-- wyjsciowy sygnal typu 'bit'
  is							-- czesc deklaracyjna procedury
    variable P, S : bit;				-- utworzenie zmiennych 'C' i 'S' w procedurze
    
    procedure sum(A, B :bit; S :out bit ; P :inout bit) is -- utworzenie procedury 'sum'
    begin						-- czesc wykonawcza procedury
      if (P='0') then					-- badanie czy bit przeniesienia jest rowny '0'
        S := A xor B;					-- sumowanie bitowe funkcja 'xor'
        P := A and B;					-- wyznaczenie bitu przeniesienia funkcja 'and'
      else						-- wariant dla 'P' rownego '1'
        S := A xnor B;					-- sumowanie bitowe funkcja 'xnor'
        P := A or   B;					-- wyznaczenie bitu przeniesienia funkcja 'or'
      end if;						-- zakonczenie instukcji warunkowej
    end procedure sum;					-- zakonczenie procedury
  
  begin							-- czesc wykonawcza procedury
    P := '0';						-- ustawienie wartosci poczatkowej 'P' na '0'
    for i in 0 to Y'length-1 loop			-- petla po kolejnych bitach dla identyfikatora 'i'
      sum(A(i),B(i),S,P);				-- wywolanie procedury wewnetrznej 'sum'
      Y(i) := S;					-- przypisanie zmiennej 'S' do portu 'Y(i)'
    end loop;						-- zakonczenie petli
    C := P;						-- przypisanie zmiennej'P' do portu 'C'
  end procedure sum;					-- zakonczenie procedury

  procedure sumator(					-- deklaracja procedury 'sumator'
    signal A1, A2 : in  bit_vector;			-- wejsciowe sygnaly typu  'bit_vector'
    signal Y      : out bit_vector;			-- wyjsciowy sygnal typu 'bit_vector'
    signal C      : out bit)				-- wyjsciowy sygnal typu 'bit'
  is							-- czesc deklaracyjna procedury
    variable S : bit_vector(Y'range);			-- utworzenie zmiennej 'S' w procedurze
    variable P : bit;					-- utworzenie zmiennej 'P' w procedurze
  begin							-- czesc wykonawcza procedury
    sum(A1,A2,S,P);					-- wywlanie procedury 'sum'
    Y <= S;						-- przypisanie zmiennej 'S' do portu 'Y'
    C <= P;						-- przypisanie zmiennej 'P' do portu 'C'
  end procedure sumator;				-- zakonczenie procedury

  procedure sumator(					-- deklaracja procedury 'sumator'
    signal A1, A2, A3 : in  bit_vector;			-- wejsciowe sygnaly typu  'bit_vector'
    signal Y          : out bit_vector;			-- wyjsciowy sygnal typu 'bit_vector'
    signal C          : out bit)			-- wyjsciowy sygnal typu 'bit'
  is							-- czesc deklaracyjna procedury
    variable S1, S2, S3 : bit_vector(Y'range);		-- utworzenie zmiennej 'S' w procedurze
    variable P : bit;					-- utworzenie zmiennej 'P' w procedurze
  begin							-- czesc wykonawcza procedury
    sum(A1,A2,S1(A1'range),S1(A1'length));		-- wywolanie przeciazonej procedury 'sum'
    S3 := '0'&A3;					-- przypisanie zmiennej 'S3'
    sum(S3,S1,S2,P);					-- wywolanie przeciazonej procedury 'sumator'
    --sum("0"&A3,S1,S2,P);				-- ??? wywolanie przeciazonej procedury 'sumator'
    Y <= S2;						-- przypisanie zmiennej 'S' do portu 'Y'
    C <= P;						-- przypisanie zmiennej 'P' do portu 'C'
  end procedure sumator;				-- zakonczenie procedury

begin							-- poczatek czesci wykonawczej

  sumator(A1, A2, YA, CA);				-- wywolanie przeciazonej procedury 'sumator'
  sumator(A1, A2, A3, YB, CB);				-- wywolanie przeciazonej procedury 'sumator'

end architecture cialo;					-- zakonczenie deklaracji ciala 'cialo'
