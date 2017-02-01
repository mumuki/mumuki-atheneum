require 'spec_helper'
require 'ostruct'

describe TestResultHelper do
  helper IconsHelper
  helper TestResultHelper

  let(:html) { render_test_results assignment }

  context 'structured results' do
    context 'when single passed submission' do
      let(:assignment) { OpenStruct.new(
        test_results: [{title: '2 is 2', status: :passed, result: ''}],
        output_content_type: Mumukit::ContentType::Plain) }

      it { expect(html).to be_html_safe }
      it { expect(html).to include "<i class=\"fa fa-check-circle text-success status-icon\"></i>" }
      it { expect(html).to include "2 is 2" }
    end

    context 'when single failed submission' do
      context 'when plain results' do
        let(:assignment) { OpenStruct.new(
          test_results: [{title: '2 is 2', status: :failed, result: 'something _went_ wrong'}],
          output_content_type: Mumukit::ContentType::Plain) }

        it { expect(html).to include "<i class=\"fa fa-times-circle text-danger status-icon\"></i>" }
        it { expect(html).to include "<strong class=\"example-title\">2 is 2</strong>" }
        it { expect(html).to include "<pre>something _went_ wrong</pre>" }
      end

      context 'when markdown results' do
        let(:assignment) { OpenStruct.new(
          test_results: [{title: '2 is 2', status: :failed, result: 'something went _really_ wrong'}],
          output_content_type: Mumukit::ContentType::Markdown) }

        it { expect(html).to include "<i class=\"fa fa-times-circle text-danger status-icon\"></i>" }
        it { expect(html).to include "<strong class=\"example-title\">2 is 2</strong>" }
        it { expect(html).to include "<p>something went <em>really</em> wrong</p>" }
      end
    end
  end

  context 'unstructured results' do
    let(:assignment) { OpenStruct.new(result_html: '<pre>ooops, something went wrong</pre>'.html_safe) }

    it { expect(html).to be_html_safe }
    it { expect(html).to eq '<pre>ooops, something went wrong</pre>' }
  end
end
