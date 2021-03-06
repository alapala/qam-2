* ====================================================================
  Execute one-year buy-and-hold minimum variance and tangent portfolio
  strategies for &mFirstYear to &mFinalYear.
  ==================================================================== ;

* --------------------------------------------------------------------
  Use preceding 5 years to compute portfolio weights.
  -------------------------------------------------------------------- ;
%LET lookback = 5;
%execute_mv_and_tn_strategies(from=&mFirstYear., to=&mFinalYear.,
    each=&lookback.,
    data_prefix=ws.Top&mStockLimit._daily,
    data_index=ws.Top&mStockLimit._by_year, work_prefix=work.Period,
    out_prefix=ws.Hist&lookback.yr)
RUN;

* --------------------------------------------------------------------
  Constrained: Use preceding 5 years to compute portfolio weights with
  0% minimum weight and 10% maximum weight.
  -------------------------------------------------------------------- ;

%MACRO constrained_portfolios_mv_tn(from=, to=, each=,
    data_prefix=, data_index=, work_prefix=, out_prefix=);
    %DO portfolio_year = &from. %TO &to.;
        * Build data set for look-back period. ;
        %build_period_data(prefix=&data_prefix., for=&portfolio_year,
            preceding=&each., index=&data_index., indexout=&work_prefix._index,
            out=&work_prefix._daily)
        * Construct portfolio and compute returns. ;
        %cnstrportfolio_buy_hold_one_year(year=&portfolio_year., preceding=&each.,
            histdata=&work_prefix._daily, prefix=&work_prefix.,
            mvwout=&out_prefix._mv_weights_&portfolio_year.,
            mvout=&out_prefix._mv_returns_&portfolio_year.,
            tnwout=&out_prefix._tn_weights_&portfolio_year.,
            tnout=&out_prefix._tn_returns_&portfolio_year.)
        %END;
    %MEND constrained_portfolios_mv_tn;

%LET lookback = 5;
%constrained_portfolios_mv_tn(from=&mFirstYear., to=&mFinalYear.,
    each=&lookback., data_prefix=ws.Top&mStockLimit._daily,
    data_index=ws.Top&mStockLimit._by_year, work_prefix=work.Period,
    out_prefix=ws.Hist&lookback.yrcnstr)
RUN;

* --------------------------------------------------------------------
  Use preceding 2 years to compute portfolio weights.
  -------------------------------------------------------------------- ;
%LET lookback = 2;
%execute_mv_and_tn_strategies(from=&mFirstYear., to=&mFinalYear.,
    each=&lookback.,
    data_prefix=ws.Top&mStockLimit._daily,
    data_index=ws.Top&mStockLimit._by_year, work_prefix=work.Period,
    out_prefix=ws.Hist&lookback.yr)
RUN;

* --------------------------------------------------------------------
  Constrained: Use preceding 2 years to compute portfolio weights with
  0% minimum weight and 10% maximum weight.
  -------------------------------------------------------------------- ;
%LET lookback = 2;
%constrained_portfolios_mv_tn(from=&mFirstYear., to=&mFinalYear.,
    each=&lookback., data_prefix=ws.Top&mStockLimit._daily,
    data_index=ws.Top&mStockLimit._by_year, work_prefix=work.Period,
    out_prefix=ws.Hist&lookback.yrcnstr)
RUN;

* --------------------------------------------------------------------
  Output data.
  -------------------------------------------------------------------- ;

* type must be either returns or weights. ;
%MACRO output_portfolios(dsprefix=, type=, from=, to=);
    DATA &dsprefix._&type._agg;
        SET %DO i = &from. %TO &to.; &dsprefix._&type._&i. %END; ;
        %IF &type. = returns %THEN %DO;
            IF NOT MISSING(year);
            %END;
        %ELSE %IF &type. = weights %THEN %DO;
            IF NOT MISSING(wt);
            IF MISSING(endwt) THEN endwt = 0;
            %END;
    %MEND output_portfolios;

%LET ds = ws.Hist5yrcnstr_tn;
%LET typ = returns;
%output_portfolios(dsprefix=&ds., type=&typ., from=1970, to=1971)
RUN;

PROC EXPORT DATA=&ds._&typ._agg OUTFILE="&sasdata\&rsdir.\&ds._&typ._agg.xls"
    REPLACE;
RUN;
