@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Biglietti - Proiection'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_BIGLIETTO_FM
  provider contract transactional_query //risoluzione warning con ctrl+1
  as projection on ZR_BIGLIETTO_FM
{
  key IdBiglietto,
      CreatoDa,
      CreatoA,
      ModificatoDa,
      ModificatoA, 
      Modificato //campo calcolato nella cds principale
}
