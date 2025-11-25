@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Biglietti'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_BIGLIETTO_FM
  as select from zbiglietto_nn_fm as zbiglietto
{
  key zbiglietto.id_biglietto  as IdBiglietto,
      zbiglietto.creato_da     as CreatoDa,
      @Semantics: {
      systemDateTime: {
        createdAt: true
      }
      }
      zbiglietto.creato_a      as CreatoA,
      @Semantics.user.lastChangedBy: true
      zbiglietto.modificato_da as ModificatoDa,
      @Semantics.systemDateTime.lastChangedAt: true
      zbiglietto.modificato_a  as ModificatoA,
      case when creato_a = modificato_a
      then ' '
      else 'X'
      end                      as Modificato
}
