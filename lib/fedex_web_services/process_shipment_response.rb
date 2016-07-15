require 'base64'

module FedexWebServices
  class ProcessShipmentResponse < Response
    def label
      label = contents.completedShipmentDetail.completedPackageDetails.first.label
      Base64.decode64(label.parts.map { |p| Base64.decode64(p.image) } * "")
    end

    def tracking_number
      contents.completedShipmentDetail.completedPackageDetails[0].trackingIds[0].trackingNumber
    rescue
      raise Api::ServiceException, "Unable to extract tracking number from response"
    end

    def package_rate
      details = contents.completedShipmentDetail.completedPackageDetails.first

      details.packageRating.packageRateDetails.inject(0) do |acc, rate|
        rate.rateType == FedexWebServices::Soap::Ship::ReturnedRateType::PAYOR_ACCOUNT_PACKAGE ?
            acc + BigDecimal.new(rate.netCharge.amount) :
            acc
      end
    rescue
      raise Api::ServiceException, "Unable to extract rate information from response"
    end
  end
end
